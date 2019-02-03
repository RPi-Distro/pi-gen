/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "NetworkSettings.h"

#include <string>
#include <vector>

#include <wpi/FileSystem.h>
#include <wpi/MathExtras.h>
#include <wpi/SmallString.h>
#include <wpi/json.h>
#include <wpi/raw_istream.h>
#include <wpi/raw_ostream.h>
#include <wpi/uv/Process.h>
#include <wpi/uv/util.h>

namespace uv = wpi::uv;

#define GEN_MARKER "###### BELOW THIS LINE EDITED BY RPICONFIGSERVER ######"

/*
 Format of generated portion for static:

   interface eth0
   static ip_address=<networkAddress>/<networkMask as CIDR>
   static routers=<networkGateway>
   static domain_name_servers=<networkDNS>

 For static fallback:

   profile static_eth0
   static ip_address=<networkAddress>/<networkMask as CIDR>
   static routers=<networkGateway>
   static domain_name_servers=<networkDNS>
   interface eth0
   fallback static_eth0
 */

wpi::StringRef CidrToNetmask(unsigned int cidr,
                             wpi::SmallVectorImpl<char>& buf) {
  in_addr addr = { htonl(wpi::maskLeadingOnes<uint32_t>(cidr)) };
  wpi::uv::AddrToName(addr, &buf);
  return wpi::StringRef(buf.data(), buf.size());
}

bool NetmaskToCidr(wpi::StringRef netmask, unsigned int* cidr) {
  in_addr addr;
  if (wpi::uv::NameToAddr(netmask, &addr) != 0) return false;
  uint32_t hostAddr = ntohl(addr.s_addr);
  auto leadingOnes = wpi::countLeadingOnes(hostAddr);
  auto trailingZeros = wpi::countTrailingZeros(hostAddr);
  if (leadingOnes + trailingZeros != 32) return false;
  *cidr = leadingOnes;
  return true;
}

std::shared_ptr<NetworkSettings> NetworkSettings::GetInstance() {
  static auto inst = std::make_shared<NetworkSettings>(private_init{});
  return inst;
}

void NetworkSettings::Set(Mode mode, wpi::StringRef address,
                          wpi::StringRef mask, wpi::StringRef gateway,
                          wpi::StringRef dns,
                          std::function<void(wpi::StringRef)> onFail) {
  // validate and sanitize inputs
  wpi::SmallString<32> addressOut;
  unsigned int cidr;
  wpi::SmallString<32> gatewayOut;
  wpi::SmallString<128> dnsOut;

  // address
  in_addr addressAddr;
  if (wpi::uv::NameToAddr(address, &addressAddr) != 0) {
    wpi::SmallString<128> err;
    err += "invalid address '";
    err += address;
    err += "'";
    onFail(err);
    return;
  }
  wpi::uv::AddrToName(addressAddr, &addressOut);

  // mask
  if (!NetmaskToCidr(mask, &cidr)) {
    wpi::SmallString<128> err;
    err += "invalid netmask '";
    err += mask;
    err += "'";
    onFail(err);
    return;
  }

  // gateway (may be blank)
  in_addr gatewayAddr;
  if (wpi::uv::NameToAddr(gateway, &gatewayAddr) == 0)
    wpi::uv::AddrToName(gatewayAddr, &gatewayOut);

  // dns
  wpi::SmallVector<wpi::StringRef, 4> dnsStrs;
  wpi::SmallString<32> oneDnsOut;
  bool first = true;
  dns.split(dnsStrs, ' ', -1, false);
  for (auto dnsStr : dnsStrs) {
    in_addr dnsAddr;
    if (wpi::uv::NameToAddr(dnsStr, &dnsAddr) != 0) {
      wpi::SmallString<128> err;
      err += "invalid DNS address '";
      err += dnsStr;
      err += "'";
      onFail(err);
      return;
    }
    wpi::uv::AddrToName(dnsAddr, &oneDnsOut);
    if (!first) dnsOut += ' ';
    first = false;
    dnsOut += oneDnsOut;
  }

  // read file (up to but not including the marker)
  std::vector<std::string> lines;
  std::error_code ec;
  {
    wpi::raw_fd_istream is(DHCPCD_CONF, ec);
    if (ec) {
      onFail("could not read " DHCPCD_CONF);
      return;
    }

    wpi::SmallString<256> lineBuf;
    while (!is.has_error()) {
      wpi::StringRef line = is.getline(lineBuf, 256).trim();
      if (line == GEN_MARKER) break;
      lines.emplace_back(line);
    }
  }

  // write file
  {
    // write original lines
    wpi::raw_fd_ostream os(DHCPCD_CONF, ec, wpi::sys::fs::F_Text);
    if (ec) {
      onFail("could not write " DHCPCD_CONF);
      return;
    }
    for (auto&& line : lines)
      os << line << '\n';

    // write marker
    os << GEN_MARKER << '\n';

    // write generated config
    switch (mode) {
      case kDhcp:
        break;  // nothing required
      case kStatic:
        os << "interface eth0\n";
        os << "static ip_address=" << addressOut << '/' << cidr << '\n';
        if (!gatewayOut.empty()) os << "static routers=" << gatewayOut << '\n';
        if (!dnsOut.empty())
          os << "static domain_name_servers=" << dnsOut << '\n';
        break;
      case kDhcpStatic:
        os << "profile static_eth0\n";
        os << "static ip_address=" << addressOut << '/' << cidr << '\n';
        if (!gatewayOut.empty()) os << "static routers=" << gatewayOut << '\n';
        if (!dnsOut.empty())
          os << "static domain_name_servers=" << dnsOut << '\n';
        os << "interface eth0\n";
        os << "fallback static_eth0\n";
        break;
    }
  }

  // tell dhcpcd to reload config
  if (auto proc =
          uv::Process::Spawn(m_loop, "/sbin/dhcpcd", "/sbin/dhcpcd", "-n")) {
    proc->exited.connect([p = proc.get()](int64_t, int) { p->Close(); });
  }

  UpdateStatus();
}

void NetworkSettings::UpdateStatus() { status(GetStatusJson()); }

wpi::json NetworkSettings::GetStatusJson() {
  std::error_code ec;
  wpi::raw_fd_istream is(DHCPCD_CONF, ec);
  if (ec) {
    wpi::errs() << "could not read " DHCPCD_CONF "\n";
    return wpi::json();
  }

  wpi::json j = {{"type", "networkSettings"}, {"networkApproach", "dhcp"}};

  wpi::SmallString<256> lineBuf;
  bool foundMarker = false;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line == GEN_MARKER) foundMarker = true;
    if (!foundMarker) continue;
    if (line.empty()) continue;
    if (line.startswith("static ip_address")) {
      j["networkApproach"] = "static";

      wpi::StringRef value = line.split('=').second.trim();
      wpi::StringRef cidrStr;
      std::tie(j["networkAddress"], cidrStr) = value.split('/');

      unsigned int cidrInt;
      if (!cidrStr.getAsInteger(10, cidrInt)) {
        wpi::SmallString<64> netmaskBuf;
        j["networkMask"] = CidrToNetmask(cidrInt, netmaskBuf);
      }
    } else if (line.startswith("static routers")) {
      j["networkGateway"] = line.split('=').second.trim();
    } else if (line.startswith("static domain_name_servers")) {
      j["networkDNS"] = line.split('=').second.trim();
    } else if (line.startswith("fallback")) {
      j["networkApproach"] = "dhcp-fallback";
    }
  }

  return j;
}
