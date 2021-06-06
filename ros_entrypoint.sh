#!/bin/bash
set -e

source /opt/ros/foxy/setup.bash
source /ros2_ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///cyclonedds.xml

# TODO: 
# Zrobić w firmwarze na STM32 serwis ROS2: "get_version", ktory zwraca wiadomosc z biezaca wersja.
# - Jezeli wersja fv na STM32 jest taka sama, to nie przechodzimy dalej
# - Jezeli wersja fv na STM32 jest inna niz ta w tym obrazku Dockera, albo nie ma wcale odpowiedzi, to robimy:

/flash_firmware.sh

exec "$@"