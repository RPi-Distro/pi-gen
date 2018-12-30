/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "MyHttpConnection.h"

#include <unistd.h>
#include <uv.h>

#include <wpi/FileSystem.h>
#include <wpi/SmallVector.h>
#include <wpi/UrlParser.h>
#include <wpi/raw_ostream.h>
#include <wpi/raw_uv_ostream.h>
#include <wpi/uv/Request.h>

#include "WebSocketHandlers.h"

#define ZIPS_DIR "/home/pi/zips"

namespace uv = wpi::uv;

// static resources
namespace wpi {
StringRef GetResource_bootstrap_4_1_min_js_gz();
StringRef GetResource_coreui_2_1_min_css_gz();
StringRef GetResource_coreui_2_1_min_js_gz();
StringRef GetResource_feather_4_8_min_js_gz();
StringRef GetResource_jquery_3_3_slim_min_js_gz();
StringRef GetResource_popper_1_14_min_js_gz();
StringRef GetResource_wpilib_128_png();
}  // namespace wpi
wpi::StringRef GetResource_frcvision_css();
wpi::StringRef GetResource_frcvision_js();
wpi::StringRef GetResource_index_html();

MyHttpConnection::MyHttpConnection(std::shared_ptr<wpi::uv::Stream> stream)
    : HttpServerConnection(stream), m_websocketHelper(m_request) {
  // Handle upgrade event
  m_websocketHelper.upgrade.connect([this] {
    //wpi::errs() << "got websocket upgrade\n";
    // Disconnect HttpServerConnection header reader
    m_dataConn.disconnect();
    m_messageCompleteConn.disconnect();

    // Accepting the stream may destroy this (as it replaces the stream user
    // data), so grab a shared pointer first.
    auto self = shared_from_this();

    // Accept the upgrade
    auto ws = m_websocketHelper.Accept(m_stream, "frcvision");

    // Connect the websocket open event to our connected event.
    // Pass self to delay destruction until this callback happens
    ws->open.connect_extended([self, s = ws.get()](auto conn, wpi::StringRef) {
      wpi::errs() << "websocket connected\n";
      InitWs(*s);
      conn.disconnect();  // one-shot
    });
    ws->text.connect([s = ws.get()](wpi::StringRef msg, bool) {
      ProcessWsText(*s, msg);
    });
    ws->binary.connect([s = ws.get()](wpi::ArrayRef<uint8_t> msg, bool) {
      ProcessWsBinary(*s, msg);
    });
  });
}

class SendfileReq : public uv::RequestImpl<SendfileReq, uv_fs_t> {
 public:
  SendfileReq(uv_file out, uv_file in, int64_t inOffset, size_t len)
      : m_out(out), m_in(in), m_inOffset(inOffset), m_len(len) {
    error = [this](uv::Error err) { GetLoop().error(err); };
  }

  uv::Loop& GetLoop() const {
    return *static_cast<uv::Loop*>(GetRaw()->loop->data);
  }

  int Send(uv::Loop& loop) {
    int err = uv_fs_sendfile(loop.GetRaw(), GetRaw(), m_out, m_in, m_inOffset,
                             m_len, [](uv_fs_t* req) {
                               auto& h = *static_cast<SendfileReq*>(req->data);
                               if (req->result < 0) {
                                 h.ReportError(req->result);
                                 h.complete();
                                 h.Release();
                                 return;
                               }

                               h.m_inOffset += req->result;
                               h.m_len -= req->result;
                               if (h.m_len == 0) {
                                 // done
                                 h.complete();
                                 h.Release();  // this is always a one-shot
                                 return;
                               }

                               // need to send more
                               h.Send(h.GetLoop());
                             });
    if (err < 0) {
      ReportError(err);
      complete();
    }
    return err;
  }

  wpi::sig::Signal<> complete;

 private:
  uv_file m_out;
  uv_file m_in;
  int64_t m_inOffset;
  size_t m_len;
};

void Sendfile(uv::Loop& loop, uv_file out, uv_file in, int64_t inOffset,
              size_t len, std::function<void()> complete) {
  auto req = std::make_shared<SendfileReq>(out, in, inOffset, len);
  if (complete) req->complete.connect(complete);
  int err = req->Send(loop);
  if (err >= 0) req->Keep();
}

void MyHttpConnection::SendFileResponse(int code, const wpi::Twine& codeText,
                                        const wpi::Twine& contentType,
                                        const wpi::Twine& filename,
                                        const wpi::Twine& extraHeader) {
  // open file
  int infd;
  if (wpi::sys::fs::openFileForRead(filename, infd)) {
    SendError(404);
    return;
  }

  // get status (to get file size)
  wpi::sys::fs::file_status status;
  if (wpi::sys::fs::status(infd, status)) {
    SendError(404);
    ::close(infd);
    return;
  }

  uv_os_fd_t outfd;
  int err = uv_fileno(m_stream.GetRawHandle(), &outfd);
  if (err < 0) {
    m_stream.GetLoopRef().ReportError(err);
    SendError(404);
    ::close(infd);
    return;
  }

  wpi::SmallVector<uv::Buffer, 4> toSend;
  wpi::raw_uv_ostream os{toSend, 4096};
  BuildHeader(os, code, codeText, contentType, status.getSize(), extraHeader);
  SendData(os.bufs(), false);

  // close after write completes if we aren't keeping alive
  // since we're using sendfile, set socket to blocking
  m_stream.SetBlocking(true);
  Sendfile(m_stream.GetLoopRef(), outfd, infd, 0, status.getSize(),
           [ infd, closeAfter = !m_keepAlive, stream = &m_stream ] {
             ::close(infd);
             if (closeAfter)
               stream->Close();
             else
               stream->SetBlocking(false);
           });
}

void MyHttpConnection::ProcessRequest() {
  //wpi::errs() << "HTTP request: '" << m_request.GetUrl() << "'\n";
  wpi::UrlParser url{m_request.GetUrl(),
                     m_request.GetMethod() == wpi::HTTP_CONNECT};
  if (!url.IsValid()) {
    // failed to parse URL
    SendError(400);
    return;
  }

  wpi::StringRef path;
  if (url.HasPath()) path = url.GetPath();
  //wpi::errs() << "path: \"" << path << "\"\n";

  wpi::StringRef query;
  if (url.HasQuery()) query = url.GetQuery();
  //wpi::errs() << "query: \"" << query << "\"\n";

  const bool isGET = m_request.GetMethod() == wpi::HTTP_GET;
  if (isGET && (path.equals("/") || path.equals("/index.html"))) {
    SendStaticResponse(200, "OK", "text/html", GetResource_index_html(), false);
  } else if (isGET && path.equals("/frcvision.css")) {
    SendStaticResponse(200, "OK", "text/css", GetResource_frcvision_css(),
                       false);
  } else if (isGET && path.equals("/frcvision.js")) {
    SendStaticResponse(200, "OK", "text/javascript", GetResource_frcvision_js(),
                       false);
  } else if (isGET && path.equals("/bootstrap.min.js")) {
    SendStaticResponse(200, "OK", "text/javascript",
                       wpi::GetResource_bootstrap_4_1_min_js_gz(), true);
  } else if (isGET && path.equals("/coreui.min.css")) {
    SendStaticResponse(200, "OK", "text/css",
                       wpi::GetResource_coreui_2_1_min_css_gz(), true);
  } else if (isGET && path.equals("/coreui.min.js")) {
    SendStaticResponse(200, "OK", "text/javascript",
                       wpi::GetResource_coreui_2_1_min_js_gz(), true);
  } else if (isGET && path.equals("/feather.min.js")) {
    SendStaticResponse(200, "OK", "text/javascript",
                       wpi::GetResource_feather_4_8_min_js_gz(), true);
  } else if (isGET && path.equals("/jquery-3.3.1.slim.min.js")) {
    SendStaticResponse(200, "OK", "text/javascript",
                       wpi::GetResource_jquery_3_3_slim_min_js_gz(), true);
  } else if (isGET && path.equals("/popper.min.js")) {
    SendStaticResponse(200, "OK", "text/javascript",
                       wpi::GetResource_popper_1_14_min_js_gz(), true);
  } else if (isGET && path.equals("/wpilib.png")) {
    SendStaticResponse(200, "OK", "image/png",
                       wpi::GetResource_wpilib_128_png(), false);
  } else if (isGET && path.startswith("/") && path.endswith(".zip") &&
             !path.contains("..")) {
    SendFileResponse(200, "OK", "application/zip", wpi::Twine(ZIPS_DIR) + path);
  } else {
    SendError(404, "Resource not found");
  }
}
