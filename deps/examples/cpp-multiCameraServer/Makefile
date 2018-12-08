EXE=multiCameraServerExample
DESTDIR?=/home/pi/

.PHONY: clean build install

build: ${EXE}

install: build
	cp ${EXE} runCamera ${DESTDIR}

clean:
	rm ${EXE} *.o

${EXE}: main.o
	${CXX} -o $@ $< -L/usr/local/frc/lib -lcameraserver -lcscore -lntcore -lwpiutil

.cpp.o:
	${CXX} -O -c -o $@ -I/usr/local/frc/include $<
