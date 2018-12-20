/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "VisionSettings.h"

#include <wpi/FileSystem.h>
#include <wpi/json.h>
#include <wpi/raw_istream.h>
#include <wpi/raw_ostream.h>

#include "VisionStatus.h"

std::shared_ptr<VisionSettings> VisionSettings::GetInstance() {
  static auto inst = std::make_shared<VisionSettings>(private_init{});
  return inst;
}

void VisionSettings::Set(const wpi::json& data,
                         std::function<void(wpi::StringRef)> onFail) {
  {
    // write file
    std::error_code ec;
    wpi::raw_fd_ostream os(FRC_JSON, ec, wpi::sys::fs::F_Text);
    if (ec) {
      onFail("could not write " FRC_JSON);
      return;
    }
    data.dump(os, 4);
    os << '\n';
  }

  // terminate vision process so it reloads the file
  VisionStatus::GetInstance()->Terminate(onFail);

  UpdateStatus();
}

void VisionSettings::UpdateStatus() { status(GetStatusJson()); }

wpi::json VisionSettings::GetStatusJson() {
  std::error_code ec;
  wpi::raw_fd_istream is(FRC_JSON, ec);
  if (ec) {
    wpi::errs() << "could not read " FRC_JSON "\n";
    return wpi::json();
  }

  try {
    wpi::json j = {{"type", "visionSettings"},
                   {"settings", wpi::json::parse(is)}};
    return j;
  } catch (wpi::json::exception& e) {
    wpi::errs() << "could not parse " FRC_JSON "\n";
    return wpi::json();
  }
}
