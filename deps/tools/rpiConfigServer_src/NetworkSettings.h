/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef RPICONFIGSERVER_NETWORKSETTINGS_H_
#define RPICONFIGSERVER_NETWORKSETTINGS_H_

#include <functional>
#include <memory>

#include <wpi/Signal.h>
#include <wpi/StringRef.h>
#include <wpi/uv/Loop.h>

namespace wpi {
class json;
}  // namespace wpi

class NetworkSettings {
  struct private_init {};

 public:
  explicit NetworkSettings(const private_init&) {}
  NetworkSettings(const NetworkSettings&) = delete;
  NetworkSettings& operator=(const NetworkSettings&) = delete;

  void SetLoop(std::shared_ptr<wpi::uv::Loop> loop) {
    m_loop = std::move(loop);
  }

  enum Mode { kDhcp, kStatic, kDhcpStatic };

  void Set(Mode mode, wpi::StringRef address, wpi::StringRef mask,
           wpi::StringRef gateway, wpi::StringRef dns,
           std::function<void(wpi::StringRef)> onFail);

  void UpdateStatus();

  wpi::json GetStatusJson();

  wpi::sig::Signal<const wpi::json&> status;

  static std::shared_ptr<NetworkSettings> GetInstance();

 private:
  std::shared_ptr<wpi::uv::Loop> m_loop;
};

#endif  // RPICONFIGSERVER_NETWORKSETTINGS_H_
