EXE=multiCameraServerExample
DESTDIR?=/home/pi/

.PHONY: clean build install

build: ${EXE}

install: build
	cp ${EXE} runCamera ${DESTDIR}

clean:
	rm ${EXE} *.o

${EXE}: main.o
	${CXX} -pthread -o $@ $< \
	    -L/usr/local/frc/lib \
	    -lwpilibc \
	    -lwpiHal \
	    -lcameraserver \
	    -lcscore \
	    -lntcore \
	    -lwpiutil \
	    -lopencv_ml \
	    -lopencv_objdetect \
	    -lopencv_shape \
	    -lopencv_stitching \
	    -lopencv_superres \
	    -lopencv_videostab \
	    -lopencv_calib3d \
	    -lopencv_features2d \
	    -lopencv_highgui \
	    -lopencv_videoio \
	    -lopencv_imgcodecs \
	    -lopencv_video \
	    -lopencv_photo \
	    -lopencv_imgproc \
	    -lopencv_flann \
	    -lopencv_core

.cpp.o:
	${CXX} -pthread -O -c -o $@ -I/usr/local/frc/include $<
