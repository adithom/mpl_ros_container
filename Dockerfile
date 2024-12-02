FROM ros:kinetic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        libopencv-dev \
        python-catkin-tools \
        build-essential \
        cmake \
        python-pip \
        ros-kinetic-rviz \
        ros-kinetic-pcl-ros \
        libsdl1.2-dev \
        libsdl-image1.2-dev \
        python-rosdep \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        mesa-utils \
        libx11-dev \
        libxrender-dev \
        libxtst-dev \
        libxi-dev \
        libglu1-mesa \
        libegl1-mesa && \
    rm -rf /var/lib/apt/lists/*

RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
        rosdep init; \
    fi && \
    rosdep update

ENV CATKIN_WS=/root/catkin_ws
RUN mkdir -p $CATKIN_WS/src

COPY mpl_ros $CATKIN_WS/src/mpl_ros

WORKDIR $CATKIN_WS

RUN git clone https://github.com/catkin/catkin_simple.git src/catkin_simple

RUN apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash && \
    catkin config -DCMAKE_BUILD_TYPE=Release && \
    catkin build -j$(nproc)"

RUN echo "source /opt/ros/kinetic/setup.bash && source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]