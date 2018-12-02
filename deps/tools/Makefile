COMPILER=../02-extract/raspbian9/bin/arm-raspbian9-linux-gnueabihf-

ALL: setuidgids _cscore.so

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
