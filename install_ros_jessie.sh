#!/bin/bash
#
# Author: Pedro valero
#
# Description: This script has been made to install ROS in Debian jessie

sudo pip install --upgrade setuptools

sudo pip install -U rosdep rosinstall_generator wstool rosinstall

sudo rosdep init

rosdep update

mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws

rosinstall_generator desktop_full --rosdistro jade --deps --wet-only --tar > jade-desktop-full-wet.rosinstall
wstool init -j8 src jade-desktop-full-wet.rosinstall

# If wstool init fails or is interrupted, you can resume the download by running: wstool update -j 4 -t src

sudo apt-key update
sudo apt-get update

##export ROS_OS_OVERRIDE="Debian:8.1:jessie"  # This line must be completed correctly
##rosdep update
###rosdep install --from-paths src --ignore-src --rosdistro jade -y
##rosdep install -a --os=Debian:jessie
##
##sudo apt-get install python-empy

#CMake Error at CMakeLists.txt:6 (find_package):
#  By not providing "Findconsole_bridge.cmake" in CMAKE_MODULE_PATH this
#  project has asked CMake to find a package configuration file provided by
#  "console_bridge", but CMake did not find one.
#
#  Could not find a package configuration file provided by "console_bridge"
#  with any of the following names:
#
#    console_bridgeConfig.cmake
#    console_bridge-config.cmake
#
#  Add the installation prefix of "console_bridge" to CMAKE_PREFIX_PATH or set
#  "console_bridge_DIR" to a directory containing one of the above files.  If
#  "console_bridge" provides a separate development package or SDK, be sure it
#  has been installed.
#
#
#-- Configuring incomplete, errors occurred!
#See also "/root/ros_catkin_ws/build_isolated/class_loader/CMakeFiles/CMakeOutput.log".

# Next lines come from 
#     http://wiki.ros.org/ROSberryPi/Installing%20ROS%20Indigo%20on%20Raspberry%20Pi#Dependencies_not_available_in_the_Raspbian_stable_branch
mkdir ~/ros_catkin_ws/external_src
sudo apt-get install checkinstall cmake
sudo sh -c 'echo "deb-src http://mirrordirector.raspbian.org/raspbian/ testing main contrib non-free rpi" >> /etc/apt/sources.list'
sudo apt-get update


# libconsole-bridge-dev: Install with the following: 
cd ~/ros_catkin_ws/external_src
sudo apt-get build-dep console-bridge
apt-get source -b console-bridge
sudo dpkg -i libconsole-bridge0.2_*.deb libconsole-bridge-dev_*.deb

# liblz4-dev: Install with the following: 
cd ~/ros_catkin_ws/external_src
apt-get source -b lz4
sudo dpkg -i liblz4-*.deb

# liburdfdom-headers-dev: Install with the following: 
cd ~/ros_catkin_ws/external_src
git clone https://github.com/ros/urdfdom_headers.git
cd urdfdom_headers
cmake .
sudo checkinstall make install
# When check-install asks for any changes, the name (2) needs to change from "urdfdom-headers" 
# to "liburdfdom-headers-dev" otherwise the rosdep install wont find it. 

# liburdfdom-dev: Install with the following: 
cd ~/ros_catkin_ws/external_src
sudo apt-get install libboost-test-dev libtinyxml-dev
git clone https://github.com/ros/urdfdom.git
cd urdfdom
cmake .
sudo checkinstall make install
# When check-install asks for any changes, the name (2) needs to change from "urdfdom"
# to "liburdfdom-dev" otherwise the rosdep install wont find it. 

# collada-dom-dev: Install with the following
cd ~/ros_catkin_ws/external_src
sudo apt-get install libboost-filesystem-dev libxml2-dev
wget http://downloads.sourceforge.net/project/collada-dom/Collada%20DOM/Collada%20DOM%202.4/collada-dom-2.4.0.tgz
tar -xzf collada-dom-2.4.0.tgz
cd collada-dom-2.4.0
cmake .
sudo checkinstall make install
# When check-install asks for any changes, the name (2) needs to change from "collada-dom" to 
# "collada-dom-dev" otherwise the rosdep install wont find it.

cd ~/ros_catkin_ws
rosdep install --from-paths src --ignore-src --rosdistro indigo -y -r --os=debian:wheezy

# Continuing with the nomral installation
./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo