COMPILER=../02-extract/raspbian9/bin/arm-raspbian9-linux-gnueabihf-

.PHONY: all
.SUFFIXES:

all: setuidgids _cscore.so rpiConfigServer

clean:
	rm -f setuidgids
	rm -f _cscore.so
	rm -f rpiConfigServer
	rm -f rpiConfigServer/*.o
	rm -f rpiConfigServer/resources/*.o

setuidgids: setuidgids.c
	${COMPILER}gcc -O -Wall -D_GNU_SOURCE -o $@ $<

_cscore.so: ../robotpy-cscore/src/_cscore.cpp ../robotpy-cscore/src/ndarray_converter.cpp
	${COMPILER}g++ -O -Wall -fvisibility=hidden -shared -fPIC -o $@ \
	    -I../03-build/opencv-build/install/include \
	    -I../allwpilib/wpiutil/src/main/native/include \
	    -I../allwpilib/cscore/src/main/native/include \
	    -I../02-extract/raspbian9/arm-raspbian9-linux-gnueabihf/usr/include/python3.5 \
	    -L../allwpilib/cscore/build/libs/cscore/shared/release \
	    -L../allwpilib/wpiutil/build/libs/wpiutil/shared/release \
	    -L../03-build/opencv-build/install/lib \
	    ../robotpy-cscore/src/_cscore.cpp \
	    ../robotpy-cscore/src/ndarray_converter.cpp \
	    -lcscore \
	    -lwpiutil \
	    -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_core

RPICONFIGSERVER_OBJS= \
    rpiConfigServer_src/main.o \
    rpiConfigServer_src/MyHttpConnection.o \
    rpiConfigServer_src/NetworkSettings.o \
    rpiConfigServer_src/SystemStatus.o \
    rpiConfigServer_src/VisionStatus.o \
    rpiConfigServer_src/WebSocketHandlers.o \
    rpiConfigServer_src/resources/index.html.o \
    rpiConfigServer_src/resources/frcvision.css.o \
    rpiConfigServer_src/resources/frcvision.js.o

rpiConfigServer: ${RPICONFIGSERVER_OBJS}
	${COMPILER}g++ -pthread -o $@ \
	    ${RPICONFIGSERVER_OBJS} \
	    -L../allwpilib/wpiutil/build/libs/wpiutil/static/release \
	    -lwpiutil
	${COMPILER}objcopy --only-keep-debug $@ $@.debug
	${COMPILER}strip -g $@

%.o: %.cpp
	${COMPILER}g++ -O -Wall -c -o $@ \
	    -I../allwpilib/wpiutil/src/main/native/include \
	    $<

%.html.cpp: %.html
	./gen_resource.py $@ $<

%.css.cpp: %.css
	./gen_resource.py $@ $<

%.js.cpp: %.js
	./gen_resource.py $@ $<

