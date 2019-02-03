/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "SystemStatus.h"

#include <wpi/SmallString.h>
#include <wpi/SmallVector.h>
#include <wpi/StringRef.h>
#include <wpi/json.h>
#include <wpi/raw_istream.h>
#include <wpi/raw_ostream.h>

std::shared_ptr<SystemStatus> SystemStatus::GetInstance() {
  static auto sysStatus = std::make_shared<SystemStatus>(private_init{});
  return sysStatus;
}

void SystemStatus::UpdateAll() {
  UpdateMemory();
  UpdateCpu();
  UpdateNetwork();
  status(GetStatusJson());
  writable(GetWritable());
}

wpi::json SystemStatus::GetStatusJson() {
  wpi::json j = {{"type", "systemStatus"}};

  size_t qty;

  // memory
  {
    uint64_t first;
    if (m_memoryFree.GetFirstLast(&first, nullptr, &qty)) {
      j["systemMemoryFree1s"] = first / 1000;
      if (qty >= 5)
        j["systemMemoryFree5s"] = m_memoryFree.GetTotal() / qty / 1000;
    }
    if (m_memoryAvail.GetFirstLast(&first, nullptr, &qty)) {
      j["systemMemoryAvail1s"] = first / 1000;
      if (qty >= 5)
        j["systemMemoryAvail5s"] = m_memoryAvail.GetTotal() / qty / 1000;
    }
  }

  // cpu
  {
    CpuData first, last;
    if (m_cpu.GetFirstLast(&first, &last, nullptr, 2)) {
      uint64_t deltaTotal = last.total - first.total;
      if (deltaTotal != 0) {
        j["systemCpuUser1s"] =
            (last.user + last.nice - first.user - first.nice) * 100 /
            deltaTotal;
        j["systemCpuSystem1s"] =
            (last.system - first.system) * 100 / deltaTotal;
        j["systemCpuIdle1s"] = (last.idle - first.idle) * 100 / deltaTotal;
      }
    }
    if (m_cpu.GetFirstLast(&first, &last, nullptr, 6)) {
      uint64_t deltaTotal = last.total - first.total;
      if (deltaTotal != 0) {
        j["systemCpuUser5s"] =
            (last.user + last.nice - first.user - first.nice) * 100 /
            deltaTotal;
        j["systemCpuSystem5s"] =
            (last.system - first.system) * 100 / deltaTotal;
        j["systemCpuIdle5s"] = (last.idle - first.idle) * 100 / deltaTotal;
      }
    }
  }

  // network
  {
    NetworkData first, last;
    if (m_network.GetFirstLast(&first, &last, nullptr, 2)) {
      j["systemNetwork1s"] = (last.recvBytes + last.xmitBytes -
                              first.recvBytes - first.xmitBytes) *
                             8 / 1000;
    }
    if (m_network.GetFirstLast(&first, &last, nullptr, 6)) {
      j["systemNetwork5s"] = (last.recvBytes + last.xmitBytes -
                              first.recvBytes - first.xmitBytes) *
                             8 / 5000;
    }
  }

  return j;
}

bool SystemStatus::GetWritable() {
  std::error_code ec;
  wpi::raw_fd_istream is("/proc/mounts", ec);
  if (ec) return false;
  wpi::SmallString<256> lineBuf;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line.empty()) break;

    wpi::SmallVector<wpi::StringRef, 8> strs;
    line.split(strs, ' ', -1, false);
    if (strs.size() < 4) continue;

    if (strs[1] == "/") return strs[3].contains("rw");
  }
  return false;
}

void SystemStatus::UpdateMemory() {
  std::error_code ec;
  wpi::raw_fd_istream is("/proc/meminfo", ec);
  if (ec) return;
  wpi::SmallString<256> lineBuf;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line.empty()) break;

    wpi::StringRef name, amtStr;
    std::tie(name, amtStr) = line.split(':');

    uint64_t amt;
    amtStr = amtStr.trim();
    if (amtStr.consumeInteger(10, amt)) continue;

    if (name == "MemFree") {
      m_memoryFree.Add(amt);
    } else if (name == "MemAvailable") {
      m_memoryAvail.Add(amt);
    }
  }
}

void SystemStatus::UpdateCpu() {
  std::error_code ec;
  wpi::raw_fd_istream is("/proc/stat", ec);
  if (ec) return;
  wpi::SmallString<256> lineBuf;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line.empty()) break;

    wpi::StringRef name, amtStr;
    std::tie(name, amtStr) = line.split(' ');
    if (name == "cpu") {
      CpuData data;

      // individual values we care about
      amtStr = amtStr.ltrim();
      if (amtStr.consumeInteger(10, data.user)) break;
      amtStr = amtStr.ltrim();
      if (amtStr.consumeInteger(10, data.nice)) break;
      amtStr = amtStr.ltrim();
      if (amtStr.consumeInteger(10, data.system)) break;
      amtStr = amtStr.ltrim();
      if (amtStr.consumeInteger(10, data.idle)) break;

      // compute total
      data.total = data.user + data.nice + data.system + data.idle;
      for (;;) {
        uint64_t amt;
        amtStr = amtStr.ltrim();
        if (amtStr.consumeInteger(10, amt)) break;
        data.total += amt;
      }

      m_cpu.Add(data);
      break;
    }
  }
}

void SystemStatus::UpdateNetwork() {
  std::error_code ec;
  wpi::raw_fd_istream is("/proc/net/dev", ec);
  if (ec) return;

  NetworkData data;

  wpi::SmallString<256> lineBuf;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line.empty()) break;

    wpi::StringRef name, amtStr;
    std::tie(name, amtStr) = line.split(':');
    name = name.trim();
    if (name.empty() || name == "lo") continue;

    wpi::SmallVector<wpi::StringRef, 20> amtStrs;
    amtStr.split(amtStrs, ' ', -1, false);
    if (amtStrs.size() < 16) continue;

    uint64_t amt;

    // receive bytes
    if (amtStrs[0].getAsInteger(10, amt)) continue;
    data.recvBytes += amt;

    // transmit bytes
    if (amtStrs[8].getAsInteger(10, amt)) continue;
    data.xmitBytes += amt;
  }

  m_network.Add(data);
}
