/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#include "Application.h"

#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

#include <wpi/FileSystem.h>
#include <wpi/json.h>
#include <wpi/raw_istream.h>
#include <wpi/raw_ostream.h>

#include "VisionStatus.h"

#define TYPE_TAG "### TYPE:"

std::shared_ptr<Application> Application::GetInstance() {
  static auto inst = std::make_shared<Application>(private_init{});
  return inst;
}

void Application::Set(wpi::StringRef appType,
                      std::function<void(wpi::StringRef)> onFail) {
  wpi::StringRef appDir;
  wpi::StringRef appEnv;
  wpi::StringRef appCommand;

  if (appType == "builtin") {
    appCommand = "/usr/local/frc/bin/multiCameraServer";
  } else if (appType == "example-java") {
    appDir = "examples/java-multiCameraServer";
    appCommand =
        "env LD_LIBRARY_PATH=/usr/local/frc/lib java -jar "
        "build/libs/java-multiCameraServer-all.jar";
  } else if (appType == "example-cpp") {
    appDir = "examples/cpp-multiCameraServer";
    appCommand = "./multiCameraServerExample";
  } else if (appType == "example-python") {
    appDir = "examples/python-multiCameraServer";
    appEnv = "export PYTHONUNBUFFERED=1";
    appCommand = "/usr/bin/python3 multiCameraServer.py";
  } else if (appType == "upload-java") {
    appCommand =
        "env LD_LIBRARY_PATH=/usr/local/frc/lib java -jar uploaded.jar";
  } else if (appType == "upload-cpp") {
    appCommand = "./uploaded";
  } else if (appType == "upload-python") {
    appEnv = "export PYTHONUNBUFFERED=1";
    appCommand = "/usr/bin/python3 uploaded.py";
  } else if (appType == "custom") {
    return;
  } else {
    wpi::SmallString<64> msg;
    msg = "unrecognized application type '";
    msg += appType;
    msg += "'";
    onFail(msg);
    return;
  }

  {
    // write file
    std::error_code ec;
    wpi::raw_fd_ostream os(EXEC_HOME "/runCamera", ec, wpi::sys::fs::F_Text);
    if (ec) {
      onFail("could not write " EXEC_HOME "/runCamera");
      return;
    }
    os << "#!/bin/sh\n";
    os << TYPE_TAG << ' ' << appType << '\n';
    os << "echo \"Waiting 5 seconds...\"\n";
    os << "sleep 5\n";
    if (!appDir.empty()) os << "cd " << appDir << '\n';
    if (!appEnv.empty()) os << appEnv << '\n';
    os << "exec " << appCommand << '\n';
  }

  // terminate vision process so it reloads
  VisionStatus::GetInstance()->Terminate(onFail);

  UpdateStatus();
}

int Application::StartUpload(wpi::StringRef appType, char* filename,
                             std::function<void(wpi::StringRef)> onFail) {
  int fd = mkstemp(filename);
  if (fd < 0) {
    wpi::SmallString<64> msg;
    msg = "could not open temporary file: ";
    msg += std::strerror(errno);
    onFail(msg);
  }
  return fd;
}

void Application::Upload(int fd, bool text, wpi::ArrayRef<uint8_t> contents) {
  // write contents
  wpi::raw_fd_ostream out(fd, false);
  if (text) {
    wpi::StringRef str(reinterpret_cast<const char*>(contents.data()),
                       contents.size());
    // convert any Windows EOL to Unix
    for (;;) {
      size_t idx = str.find("\r\n");
      if (idx == wpi::StringRef::npos) break;
      out << str.slice(0, idx) << '\n';
      str = str.slice(idx + 2, wpi::StringRef::npos);
    }
    out << str;
    // ensure file ends with EOL
    if (!str.empty() && str.back() != '\n') out << '\n';
  } else {
    out << contents;
  }
}

void Application::FinishUpload(wpi::StringRef appType, int fd,
                               const char* tmpFilename,
                               std::function<void(wpi::StringRef)> onFail) {
  wpi::StringRef filename;
  if (appType == "upload-java") {
    filename = "/uploaded.jar";
  } else if (appType == "upload-cpp") {
    filename = "/uploaded";
  } else if (appType == "upload-python") {
    filename = "/uploaded.py";
  } else {
    wpi::SmallString<64> msg;
    msg = "cannot upload application type '";
    msg += appType;
    msg += "'";
    onFail(msg);
    ::close(fd);
    return;
  }

  wpi::SmallString<64> pathname;
  pathname = EXEC_HOME;
  pathname += filename;

  // change ownership
  if (fchown(fd, APP_UID, APP_GID) == -1) {
    wpi::errs() << "could not change app ownership: " << std::strerror(errno)
                << '\n';
  }

  // set file to be executable
  if (fchmod(fd, 0775) == -1) {
    wpi::errs() << "could not change app permissions: " << std::strerror(errno)
                << '\n';
  }

  // close temporary file
  ::close(fd);

  // remove old file (need to do this as we can't overwrite a running exe)
  if (unlink(pathname.c_str()) == -1) {
    wpi::errs() << "could not remove app executable: " << std::strerror(errno)
                << '\n';
  }

  // rename temporary file to new file
  if (rename(tmpFilename, pathname.c_str()) == -1) {
    wpi::errs() << "could not rename to app executable: "
                << std::strerror(errno) << '\n';
  }

  // terminate vision process so it reloads
  VisionStatus::GetInstance()->Terminate(onFail);
}

void Application::UpdateStatus() { status(GetStatusJson()); }

wpi::json Application::GetStatusJson() {
  wpi::json j = {{"type", "applicationSettings"},
                 {"applicationType", "custom"}};

  std::error_code ec;
  wpi::raw_fd_istream is(EXEC_HOME "/runCamera", ec);
  if (ec) {
    wpi::errs() << "could not read " EXEC_HOME "/runCamera\n";
    return j;
  }

  // scan file
  wpi::SmallString<256> lineBuf;
  while (!is.has_error()) {
    wpi::StringRef line = is.getline(lineBuf, 256).trim();
    if (line.startswith(TYPE_TAG)) {
      j["applicationType"] = line.substr(strlen(TYPE_TAG)).trim();
      break;
    }
  }

  return j;
}
