/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef RPICONFIGSERVER_SYSTEMSTATUS_H_
#define RPICONFIGSERVER_SYSTEMSTATUS_H_

#include <memory>

#include <wpi/Signal.h>

#include "DataHistory.h"

namespace wpi {
class json;
}  // namespace wpi

class SystemStatus {
  struct private_init {};

 public:
  explicit SystemStatus(const private_init&) {}
  SystemStatus(const SystemStatus&) = delete;
  SystemStatus& operator=(const SystemStatus&) = delete;

  void UpdateAll();

  wpi::json GetStatusJson();
  bool GetWritable();

  wpi::sig::Signal<const wpi::json&> status;
  wpi::sig::Signal<bool> writable;

  static std::shared_ptr<SystemStatus> GetInstance();

 private:
  void UpdateMemory();
  void UpdateCpu();
  void UpdateNetwork();

  DataHistory<uint64_t, 5> m_memoryFree;
  DataHistory<uint64_t, 5> m_memoryAvail;
  struct CpuData {
    uint64_t user;
    uint64_t nice;
    uint64_t system;
    uint64_t idle;
    uint64_t total;
  };
  DataHistory<CpuData, 6> m_cpu;
  struct NetworkData {
    uint64_t recvBytes = 0;
    uint64_t xmitBytes = 0;
  };
  DataHistory<NetworkData, 6> m_network;
};

#endif  // RPICONFIGSERVER_SYSTEMSTATUS_H_
