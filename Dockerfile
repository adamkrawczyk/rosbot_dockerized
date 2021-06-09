# https://hub.docker.com/r/arm32v7/ros/ - the latest ROS 2 image for ARM32v7 is ROS 2 Eloquent
# for ROSbot 2.0
# FROM ros:eloquent-ros-base-bionic

# for ROSbot 2.0 PRO
FROM ros:eloquent-ros-base
ENV ROS_DISTRO=eloquent
SHELL ["/bin/bash", "-c"]

# Fix ros key
# NOTE: Needed because of this bug https://github.com/osrf/docker_images/issues/535
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install ROS 2 deppendencies (Cyclone DDS) and others
RUN sudo apt update 
RUN sudo apt upgrade -y 
RUN sudo apt install -y \
    ros-eloquent-rmw-cyclonedds-cpp \
    wget \ 
    ros-eloquent-ament-cmake \ 
    ros-eloquent-gazebo-ros-pkgs 
RUN sudo rm -rf /var/lib/apt/lists/*

RUN mkdir stm32_fw && \
    wget -O /stm32_fw/firmware.bin https://husarion-files.s3-eu-west-1.amazonaws.com/rosbot-2.0-fw-v0.14.4.bin

# Install ROSbot packages for: RPLIDAR, ORBBEC ASTRA and STM32 FW bridge
#RUN . /opt/ros/foxy/setup.sh

RUN mkdir -p ros2_ws/src && cd ros2_ws/src && \
    git clone https://github.com/lukaszmitka/rplidar_ros.git --single-branch --branch=ros2-scan-modes && \
    git clone https://github.com/husarion/ros_astra_camera  --single-branch --branch=foxy && \
    git clone https://github.com/husarion/rosbot_description  --single-branch --branch=foxy 
WORKDIR /ros2_ws
RUN apt-get -qq update && rosdep install -y \
    --from-paths src \
    --ignore-src 
RUN  . /opt/ros/$ROS_DISTRO/setup.sh && colcon build

# Failing at this point with the following error:
# Starting >>> astra_camera
# Starting >>> rosbot_description
# Starting >>> rplidar_ros
# --- stderr: rosbot_description
# CMake Error at CMakeLists.txt:19 (find_package):
#   By not providing "Findament_cmake.cmake" in CMAKE_MODULE_PATH this project
#   has asked CMake to find a package configuration file provided by
#   "ament_cmake", but CMake did not find one.

#   Could not find a package configuration file provided by "ament_cmake" with
#   any of the following names:

#     ament_cmakeConfig.cmake
#     ament_cmake-config.cmake

#   Add the installation prefix of "ament_cmake" to CMAKE_PREFIX_PATH or set
#   "ament_cmake_DIR" to a directory containing one of the above files.  If
#   "ament_cmake" provides a separate development package or SDK, be sure it
#   has been installed.


# ---
# Failed   <<< rosbot_description [0.45s, exited with code 1]
# Aborted  <<< rplidar_ros [0.44s]
# Aborted  <<< astra_camera [0.46s]

# Summary: 0 packages finished [0.62s]
#   1 package failed: rosbot_description
#   2 packages aborted: astra_camera rplidar_ros
#   3 packages had stderr output: astra_camera rosbot_description rplidar_ros

COPY ./cyclonedds.xml /
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]   
CMD ["bash"]
