/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef WPIUTIL_WEBSOCKETHANDLERS_H_
#define WPIUTIL_WEBSOCKETHANDLERS_H_

#include "wpi/StringRef.h"

namespace wpi {
class WebSocket;
}  // namespace wpi

void InitWs(wpi::WebSocket& ws);
void ProcessWsText(wpi::WebSocket& ws, wpi::StringRef msg);

#endif  // WPIUTIL_WEBSOCKETHANDLERS_H_
