if(COMMAND toolchain_save_config)
  return() # prevent recursive call
endif()

set(GCC_COMPILER_VERSION "" CACHE STRING "GCC Compiler version")
set(GNU_MACHINE "arm-raspbian9-linux-gnueabi" CACHE STRING "GNU compiler triple")
set(SOFTFP no)
set(FLOAT_ABI_SUFFIX "hf")
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_SYSROOT "$ENV{ROOTFS_DIR}")

include("$ENV{ROOTFS_DIR}/usr/src/opencv-3.4.4/platforms/linux/gnu.toolchain.cmake")

if(NOT DEFINED CMAKE_C_COMPILER)
  find_program(CMAKE_C_COMPILER NAMES ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-gcc${__GCC_VER_SUFFIX})
else()
  #message(WARNING "CMAKE_C_COMPILER=${CMAKE_C_COMPILER} is defined")
endif()
if(NOT DEFINED CMAKE_CXX_COMPILER)
  find_program(CMAKE_CXX_COMPILER NAMES ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-g++${__GCC_VER_SUFFIX})
else()
  #message(WARNING "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} is defined")
endif()
if(NOT DEFINED CMAKE_LINKER)
  find_program(CMAKE_LINKER NAMES ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-ld${__GCC_VER_SUFFIX} ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-ld)
else()
  #message(WARNING "CMAKE_LINKER=${CMAKE_LINKER} is defined")
endif()
if(NOT DEFINED CMAKE_AR)
  find_program(CMAKE_AR NAMES ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-ar${__GCC_VER_SUFFIX} ${GNU_MACHINE}${FLOAT_ABI_SUFFIX}-ar)
else()
  #message(WARNING "CMAKE_AR=${CMAKE_AR} is defined")
endif()

if(NOT DEFINED ARM_LINUX_SYSROOT AND DEFINED GNU_MACHINE)
  set(ARM_LINUX_SYSROOT /usr/${GNU_MACHINE}${FLOAT_ABI_SUFFIX})
endif()

set(ARM_LINKER_FLAGS "-Wl,-rpath -Wl,$ENV{ROOTFS_DIR}/opt/vc/lib")

if(NOT DEFINED CMAKE_CXX_FLAGS)
  set(CMAKE_CXX_FLAGS           "" CACHE INTERNAL "")
  set(CMAKE_C_FLAGS             "" CACHE INTERNAL "")
  set(CMAKE_SHARED_LINKER_FLAGS "" CACHE INTERNAL "")
  set(CMAKE_MODULE_LINKER_FLAGS "" CACHE INTERNAL "")
  set(CMAKE_EXE_LINKER_FLAGS    "" CACHE INTERNAL "")

  set(CMAKE_CXX_FLAGS           "-isystem $ENV{ROOTFS_DIR}/usr/include/arm-linux-gnueabihf ${CMAKE_CXX_FLAGS} -Wno-psabi")
  set(CMAKE_C_FLAGS             "-isystem $ENV{ROOTFS_DIR}/usr/include/arm-linux-gnueabihf ${CMAKE_C_FLAGS} -Wno-psabi")
  set(CMAKE_SHARED_LINKER_FLAGS "${ARM_LINKER_FLAGS} -rdynamic ${CMAKE_SHARED_LINKER_FLAGS}")
  set(CMAKE_MODULE_LINKER_FLAGS "${ARM_LINKER_FLAGS} -rdynamic ${CMAKE_MODULE_LINKER_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS    "${ARM_LINKER_FLAGS} -rdynamic ${CMAKE_EXE_LINKER_FLAGS}")
else()
  #message(WARNING "CMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS}' is defined")
endif()

if(USE_NEON)
  message(WARNING "You use obsolete variable USE_NEON to enable NEON instruction set. Use -DENABLE_NEON=ON instead." )
  set(ENABLE_NEON TRUE)
elseif(USE_VFPV3)
  message(WARNING "You use obsolete variable USE_VFPV3 to enable VFPV3 instruction set. Use -DENABLE_VFPV3=ON instead." )
  set(ENABLE_VFPV3 TRUE)
endif()

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} ${ARM_LINUX_SYSROOT})

if(EXISTS ${CUDA_TOOLKIT_ROOT_DIR})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} ${CUDA_TOOLKIT_ROOT_DIR})
endif()

set(TOOLCHAIN_CONFIG_VARS ${TOOLCHAIN_CONFIG_VARS}
    ARM_LINUX_SYSROOT
    ENABLE_NEON
    ENABLE_VFPV3
    CUDA_TOOLKIT_ROOT_DIR
)
toolchain_save_config()

