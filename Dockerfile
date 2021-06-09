# https://hub.docker.com/r/arm32v7/ros/ - the latest ROS 2 image for ARM32v7 is ROS 2 Eloquent
# for ROSbot 2.0
# FROM ros:eloquent-ros-base-bionic

# for ROSbot 2.0 PRO
FROM osrf/ros:foxy-desktop

SHELL ["/bin/bash", "-c"]

# Fix ros key
# NOTE: Needed because of this bug https://github.com/osrf/docker_images/issues/535
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install ROS 2 deppendencies (Cyclone DDS) and others
RUN sudo apt update 
RUN sudo apt upgrade -y 
RUN sudo apt install -y \
    ros-foxy-rmw-cyclonedds-cpp \
    ros-foxy-ament-cmake \ 
    ros-foxy-gazebo-ros-pkgs \
    wget \ 
    python2
RUN sudo rm -rf /var/lib/apt/lists/*

RUN mkdir stm32_fw && \
    wget -O /stm32_fw/firmware.bin https://husarion-files.s3-eu-west-1.amazonaws.com/rosbot-2.0-fw-v0.14.4.bin

# Install ROSbot packages for: RPLIDAR, ORBBEC ASTRA and STM32 FW bridge
RUN mkdir -p ros2_ws/src && cd ros2_ws/src && \
    git clone https://github.com/lukaszmitka/rplidar_ros.git --single-branch --branch=ros2-scan-modes && \
    git clone https://github.com/husarion/ros_astra_camera  --single-branch --branch=foxy && \
    git clone https://github.com/husarion/rosbot_description  --single-branch --branch=foxy 
WORKDIR /ros2_ws
RUN apt-get -qq update && rosdep install -y \
    --from-paths src \
    --ignore-src 
RUN  source /opt/ros/foxy/setup.sh && colcon build

COPY ./cyclonedds.xml /
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]   
CMD ["bash"]
