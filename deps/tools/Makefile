SYSROOT?=../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf
COMPILER?=../02-extract/raspbian9/bin/arm-raspbian9-linux-gnueabihf-
WPILIB_SRC?=../allwpilib
WPILIB_BUILD?=../03-build/allwpilib-build
WPILIB_STATIC_BUILD?=../03-build/allwpilib-static
OPENCV_INSTALL?=../03-build/opencv-build/install
OPENCV_STATIC_INSTALL?=../03-build/opencv-static/install
EXEC_HOME?=/home/pi
FRC_JSON?=/boot/frc.json
DHCPCD_CONF?=/boot/dhcpcd.conf
APP_UID?=1000
APP_GID?=1000

.PHONY: all
.SUFFIXES:

all: setuidgids _cscore.so multiCameraServer rpiConfigServer

clean:
	rm -f setuidgids
	rm -f _cscore.so
	rm -f rpiConfigServer
	rm -f rpiConfigServer_src/*.o
	rm -f rpiConfigServer_src/resources/*.o

setuidgids: setuidgids.c
	${COMPILER}gcc -O -Wall -D_GNU_SOURCE -o $@ $<

_cscore.so: ../robotpy-cscore/src/_cscore.cpp ../robotpy-cscore/src/ndarray_converter.cpp
	${COMPILER}g++ -g -O -Wall -fvisibility=hidden -shared -fPIC -o $@ \
	    -I${OPENCV_INSTALL}/include \
	    -I${WPILIB_SRC}/wpiutil/src/main/native/include \
	    -I${WPILIB_SRC}/cscore/src/main/native/include \
	    -I${SYSROOT}/usr/include/python3.5 \
	    -L${WPILIB_BUILD}/lib \
	    -L${OPENCV_INSTALL}/lib \
	    ../robotpy-cscore/src/_cscore.cpp \
	    ../robotpy-cscore/src/ndarray_converter.cpp \
	    -lcscore \
	    -lwpiutil \
	    -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_core
	${COMPILER}objcopy --only-keep-debug $@ $@.debug
	${COMPILER}strip -g $@
	${COMPILER}objcopy --add-gnu-debuglink=$@.debug $@

multiCameraServer: multiCameraServer.cpp
	${COMPILER}g++ -pthread -g -o $@ \
	    -I${OPENCV_INSTALL}/include \
	    -I${WPILIB_SRC}/wpiutil/src/main/native/include \
	    -I${WPILIB_SRC}/cameraserver/src/main/native/include \
	    -I${WPILIB_SRC}/cscore/src/main/native/include \
	    -I${WPILIB_SRC}/ntcore/src/main/native/include \
	    -L${WPILIB_STATIC_BUILD}/lib \
	    -L${OPENCV_STATIC_INSTALL}/lib \
	    -L${OPENCV_STATIC_INSTALL}/share/OpenCV/3rdparty/lib \
	    $< \
	    -lcameraserver \
	    -lcscore \
	    -lntcore \
	    -lwpiutil \
	    -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_core \
	    -ltegra_hal -llibpng -llibjpeg-turbo -lzlib
	${COMPILER}objcopy --only-keep-debug $@ $@.debug
	${COMPILER}strip -g $@
	${COMPILER}objcopy --add-gnu-debuglink=$@.debug $@

RPICONFIGSERVER_OBJS= \
    rpiConfigServer_src/main.o \
    rpiConfigServer_src/Application.o \
    rpiConfigServer_src/MyHttpConnection.o \
    rpiConfigServer_src/NetworkSettings.o \
    rpiConfigServer_src/SystemStatus.o \
    rpiConfigServer_src/VisionSettings.o \
    rpiConfigServer_src/VisionStatus.o \
    rpiConfigServer_src/WebSocketHandlers.o \
    rpiConfigServer_src/resources/index.html.o \
    rpiConfigServer_src/resources/frcvision.css.o \
    rpiConfigServer_src/resources/frcvision.js.o

rpiConfigServer: ${RPICONFIGSERVER_OBJS}
	${COMPILER}g++ -pthread -g -o $@ \
	    ${RPICONFIGSERVER_OBJS} \
	    -L${WPILIB_STATIC_BUILD}/lib \
	    -L${OPENCV_STATIC_INSTALL}/lib \
	    -L${OPENCV_STATIC_INSTALL}/share/OpenCV/3rdparty/lib \
	    -lcscore \
	    -lwpiutil \
	    -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_core \
	    -ltegra_hal -llibpng -llibjpeg-turbo -lzlib
	${COMPILER}objcopy --only-keep-debug $@ $@.debug
	${COMPILER}strip -g $@
	${COMPILER}objcopy --add-gnu-debuglink=$@.debug $@

%.o: %.cpp
	${COMPILER}g++ -g -O -Wall -c -o $@ \
	    -I${WPILIB_SRC}/wpiutil/src/main/native/include \
	    -I${WPILIB_SRC}/cscore/src/main/native/include \
	    '-DEXEC_HOME="${EXEC_HOME}"' \
	    '-DFRC_JSON="${FRC_JSON}"' \
	    '-DDHCPCD_CONF="${DHCPCD_CONF}"' \
	    '-DAPP_UID=${APP_UID}' \
	    '-DAPP_GID=${APP_GID}' \
	    $<

%.html.cpp: %.html
	./gen_resource.py $@ $<

%.css.cpp: %.css
	./gen_resource.py $@ $<

%.js.cpp: %.js
	./gen_resource.py $@ $<

