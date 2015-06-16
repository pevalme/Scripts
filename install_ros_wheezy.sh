#!/bin/bash
#
# Author: Pedro valero
#
# Description: This script has been made to install ROS in Debian wheezy

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu wheezy main" > /etc/apt/sources.list.d/ros-latest.list'

wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O- | sudo apt-key add -

sudo sh -c 'echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/backports.list'

sudo apt-get update

sudo apt-get upgrade

sudo apt-get install python-setuptools
sudo easy_install pip
sudo pip install -U rosdep rosinstall_generator wstool rosinstall

sudo rosdep init
rosdep update

mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws

rosinstall_generator desktop --rosdistro indigo --deps --wet-only --exclude roslisp --tar > indigo-desktop-wet.rosinstall
wstool init -j8 src indigo-desktop-wet.rosinstall

# Next lines come from 
#     http://wiki.ros.org/ROSberryPi/Installing%20ROS%20Indigo%20on%20Raspberry%20Pi#Dependencies_not_available_in_the_Raspbian_stable_branch
mkdir ~/ros_catkin_ws/external_src
sudo apt-get install checkinstall cmake


# libconsole-bridge-dev: Install with the following: 
cd ~/ros_catkin_ws/external_src
sudo apt-get install libboost-system-dev libboost-thread-dev
git clone https://github.com/ros/console_bridge.git
cd console_bridge
cmake .
sudo checkinstall make install
# When check-install asks for any changes, the name (2) needs to change from "console-bridge" 
# to "libconsole-bridge-dev" otherwise rosdep install wont find it. You can also skip generating documentation.

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

# libopencv-dev
cd ~/ros_catkin_ws/external_src
git clone https://github.com/Itseez/opencv.git
mkdir opencv/release
cd opencv/release
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make
sudo checkinstall make install
# When check-install asks for any changes, the name (2) needs to change from "release" 
# to "libopencv-dev" otherwise rosdep install wont find it. 

# liblz4-dev: Install with the following: 
sudo apt-get -t wheezy-backports install liblz4-dev

# Ogre
sudo apt-get remove libogre-1.7.*
sudo apt-get install libogre-1.8-dev

# Resolving Dependencies with rosdep
cd ~/ros_catkin_ws
rosdep install --from-paths src --ignore-src --rosdistro indigo -y -r --os=debian:wheezy

# Building the catkin workspace
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo
source /opt/ros/indigo/setup.bash