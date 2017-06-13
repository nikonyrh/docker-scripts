FROM nikonyrh/spark_base
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# Based on https://github.com/janza/docker-python3-opencv/blob/master/Dockerfile

# to build:        docker build -t nikonyrh/spark_ocv_base spark_py34_opencv3
# other commands:  as with nikonyrh/spark_py34

RUN apt-get update && apt-get install -y \
        build-essential cmake \
        git wget unzip yasm \
        pkg-config libswscale-dev libtbb2 \
        libtbb-dev libjpeg-dev libpng-dev \
        libtiff-dev libjasper-dev libavformat-dev libpq-dev && \
        apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /
ENV OPENCV_VER 3.1.0

RUN wget -q https://github.com/Itseez/opencv/archive/$OPENCV_VER.zip && unzip $OPENCV_VER.zip && \
    mkdir /opencv-$OPENCV_VER/cmake_binary && cd /opencv-$OPENCV_VER/cmake_binary && \
    cmake -j4 -DBUILD_TIFF=ON \
      -DBUILD_opencv_java=OFF \
      -DWITH_CUDA=OFF -DENABLE_AVX=ON \
      -DWITH_OPENGL=ON -DWITH_OPENCL=OFF \
      -DWITH_IPP=ON    -DWITH_TBB=ON \
      -DWITH_EIGEN=ON  -DWITH_V4L=ON \
      -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$(/py3/bin/python -c "import sys; print(sys.prefix)") \
      -DPYTHON_EXECUTABLE=$(which /py3/bin/python) \
      -DPYTHON_INCLUDE_DIR=$(/py3/bin/python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
      -DPYTHON_PACKAGES_PATH=$(/py3/bin/python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. && \
    make install && rm /$OPENCV_VER.zip && rm -r /opencv-$OPENCV_VER

