DEPS_CFLAGS?=$(shell pkg-config --cflags cameraserver ntcore wpiutil)
DEPS_LIBS?=$(shell pkg-config --libs --static cameraserver ntcore wpiutil)

.PHONY: all clean

all: multiCameraServer

clean:
	rm -f multiCameraServer

multiCameraServer: src/multiCameraServer.cpp
	${CXX} -pthread -g -o $@ ${CXXFLAGS} ${DEPS_CFLAGS} $^ ${DEPS_LIBS}
