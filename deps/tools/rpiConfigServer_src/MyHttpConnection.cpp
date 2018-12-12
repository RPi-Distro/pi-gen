/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "MyHttpConnection.h"

#include "WebSocketHandlers.h"
#include "wpi/UrlParser.h"
#include "wpi/raw_ostream.h"

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
  } else {
    SendError(404, "Resource not found");
  }
}
