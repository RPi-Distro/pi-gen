ALL: setuidgids _cscore.so

setuidgids: setuidgids.c
	arm-raspbian9-linux-gnueabihf-gcc -O -Wall -D_GNU_SOURCE -o $@ $<

_cscore.so: ../../robotpy-cscore/src/_cscore.cpp ../../robotpy-cscore/src/ndarray_converter.cpp
	arm-raspbian9-linux-gnueabihf-g++ -O -Wall -shared -fPIC -o $@ \
	    -I../../thirdparty-opencv/opencv/include \
	    -I../../thirdparty-opencv/opencv/modules/core/include \
	    -I../../thirdparty-opencv/opencv/modules/calib3d/include \
	    -I../../thirdparty-opencv/opencv/modules/features2d/include \
	    -I../../thirdparty-opencv/opencv/modules/flann/include \
	    -I../../thirdparty-opencv/opencv/modules/highgui/include \
	    -I../../thirdparty-opencv/opencv/modules/imgcodecs/include \
	    -I../../thirdparty-opencv/opencv/modules/imgproc/include \
	    -I../../thirdparty-opencv/opencv/modules/ml/include \
	    -I../../thirdparty-opencv/opencv/modules/objdetect/include \
	    -I../../thirdparty-opencv/opencv/modules/photo/include \
	    -I../../thirdparty-opencv/opencv/modules/shape/include \
	    -I../../thirdparty-opencv/opencv/modules/stitching/include \
	    -I../../thirdparty-opencv/opencv/modules/superres/include \
	    -I../../thirdparty-opencv/opencv/modules/video/include \
	    -I../../thirdparty-opencv/opencv/modules/videoio/include \
	    -I../../thirdparty-opencv/opencv/modules/videostab/include \
	    -I../../thirdparty-opencv/buildShared/linux-raspbian \
	    -I../../allwpilib/wpiutil/src/main/native/include \
	    -I../../allwpilib/cscore/src/main/native/include \
	    -I/usr/local/arm-raspbian9-linux-gnueabihf/usr/include/python3.5 \
	    -L../../allwpilib/cscore/build/libs/cscore/shared/raspbian/release \
	    -L../../allwpilib/wpiutil/build/libs/wpiutil/shared/raspbian/release \
	    -L../../thirdparty-opencv/buildShared/linux-raspbian/lib \
	    ../../robotpy-cscore/src/_cscore.cpp \
	    ../../robotpy-cscore/src/ndarray_converter.cpp \
	    -lcscore \
	    -lwpiutil \
	    -lopencv_calib3d -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_shape -lopencv_stitching -lopencv_superres -lopencv_video -lopencv_videoio -lopencv_videostab -lopencv_core
