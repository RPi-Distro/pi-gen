/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef WPIUTIL_MYHTTPCONNECTION_H_
#define WPIUTIL_MYHTTPCONNECTION_H_

#include <memory>

#include "wpi/HttpServerConnection.h"
#include "wpi/WebSocketServer.h"
#include "wpi/uv/Stream.h"

class MyHttpConnection : public wpi::HttpServerConnection,
                         public std::enable_shared_from_this<MyHttpConnection> {
 public:
  explicit MyHttpConnection(std::shared_ptr<wpi::uv::Stream> stream);

 protected:
  void ProcessRequest() override;

  wpi::WebSocketServerHelper m_websocketHelper;
};

#endif  // WPIUTIL_MYHTTPCONNECTION_H_
