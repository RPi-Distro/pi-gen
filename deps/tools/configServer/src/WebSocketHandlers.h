/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef RPICONFIGSERVER_WEBSOCKETHANDLERS_H_
#define RPICONFIGSERVER_WEBSOCKETHANDLERS_H_

#include <wpi/ArrayRef.h>
#include <wpi/StringRef.h>

namespace wpi {
class WebSocket;
}  // namespace wpi

void InitWs(wpi::WebSocket& ws);
void ProcessWsText(wpi::WebSocket& ws, wpi::StringRef msg);
void ProcessWsBinary(wpi::WebSocket& ws, wpi::ArrayRef<uint8_t> msg);

#endif  // RPICONFIGSERVER_WEBSOCKETHANDLERS_H_
