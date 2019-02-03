/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include <chrono>
#include <thread>

#include <wpi/ArrayRef.h>
#include <wpi/StringRef.h>
#include <wpi/raw_ostream.h>
#include <wpi/raw_uv_ostream.h>
#include <wpi/timestamp.h>
#include <wpi/uv/Loop.h>
#include <wpi/uv/Process.h>
#include <wpi/uv/Tcp.h>
#include <wpi/uv/Timer.h>
#include <wpi/uv/Udp.h>

#include "MyHttpConnection.h"
#include "NetworkSettings.h"
#include "SystemStatus.h"
#include "VisionStatus.h"

namespace uv = wpi::uv;

static uint64_t startTime = wpi::Now();

int main(int argc, char* argv[]) {
  int port = 80;
  if (argc == 2) port = std::atoi(argv[1]);

  uv::Process::DisableStdioInheritance();

  SystemStatus::GetInstance();

  auto loop = uv::Loop::Create();

  NetworkSettings::GetInstance()->SetLoop(loop);
  VisionStatus::GetInstance()->SetLoop(loop);

  loop->error.connect(
      [](uv::Error err) { wpi::errs() << "uv ERROR: " << err.str() << '\n'; });

  auto tcp = uv::Tcp::Create(loop);

  // bind to listen address and port
  tcp->Bind("", port);

  // when we get a connection, accept it and start reading
  tcp->connection.connect([srv = tcp.get()] {
    auto tcp = srv->Accept();
    if (!tcp) return;
    // wpi::errs() << "Got a connection\n";

    // Close on error
    tcp->error.connect([s = tcp.get()](wpi::uv::Error err) {
      wpi::errs() << "stream error: " << err.str() << '\n';
      s->Close();
    });

    auto conn = std::make_shared<MyHttpConnection>(tcp);
    tcp->SetData(conn);
  });

  // start listening for incoming connections
  tcp->Listen();

  wpi::errs() << "Listening on port " << port << '\n';

  // start timer to collect system and vision status
  auto timer = uv::Timer::Create(loop);
  timer->Start(std::chrono::seconds(1), std::chrono::seconds(1));
  timer->timeout.connect([&loop] {
    SystemStatus::GetInstance()->UpdateAll();
    VisionStatus::GetInstance()->UpdateStatus();
  });

  // listen on port 6666 for console logging
  auto udpCon = uv::Udp::Create(loop);
  udpCon->Bind("127.0.0.1", 6666, UV_UDP_REUSEADDR);
  udpCon->StartRecv();
  udpCon->received.connect(
      [](uv::Buffer& buf, size_t len, const sockaddr&, unsigned) {
        VisionStatus::GetInstance()->ConsoleLog(buf, len);
      });

  // create riolog console port
  auto tcpCon = uv::Tcp::Create(loop);
  tcpCon->Bind("", 1740);

  // when we get a connection, accept it
  tcpCon->connection.connect([ srv = tcpCon.get(), udpCon ] {
    auto tcp = srv->Accept();
    if (!tcp) return;

    // close on error
    tcp->error.connect([s = tcp.get()](uv::Error err) { s->Close(); });

    // copy console log to it with headers
    udpCon->received.connect(
        [ tcpSeq = std::make_shared<uint16_t>(), tcpPtr = tcp.get() ](
            uv::Buffer & buf, size_t len, const sockaddr&, unsigned) {
          // build buffers
          wpi::SmallVector<uv::Buffer, 4> bufs;
          wpi::raw_uv_ostream out(bufs, 4096);

          // Header is 2 byte len, 1 byte type, 4 byte timestamp, 2 byte
          // sequence num
          uint32_t ts = wpi::FloatToBits((wpi::Now() - startTime) * 1.0e-6);
          uint16_t pktlen = len + 1 + 4 + 2;
          out << wpi::ArrayRef<uint8_t>(
              {static_cast<uint8_t>((pktlen >> 8) & 0xff),
               static_cast<uint8_t>(pktlen & 0xff), 12,
               static_cast<uint8_t>((ts >> 24) & 0xff),
               static_cast<uint8_t>((ts >> 16) & 0xff),
               static_cast<uint8_t>((ts >> 8) & 0xff),
               static_cast<uint8_t>(ts & 0xff),
               static_cast<uint8_t>((*tcpSeq >> 8) & 0xff),
               static_cast<uint8_t>(*tcpSeq & 0xff)});
          out << wpi::StringRef(buf.base, len);
          (*tcpSeq)++;

          // send output
          tcpPtr->Write(bufs, [](auto bufs2, uv::Error) {
            for (auto buf : bufs2) buf.Deallocate();
          });
        },
        tcp);
  });

  // start listening for incoming connections
  tcpCon->Listen();

  // run loop
  loop->Run();
}
