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
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_C_COMPILER=gcc4.4 -D CMAKE_INSTALL_PREFIX=/usr/local ..
make
make uninstall # just to check there are no older versions installed
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
# Note: Rosdep and apt-get may report that python-rosdep, python-catkin-pkg, 
#python-rospkg, and python-rosdistro failed to install; however, you can ignore this
# error because they have already been installed with pip

# Building the catkin workspace
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo
source /opt/ros/indigo/setup.bash

################
# To update your workspace, first move your existing rosinstall file so that it doesn't get overwritten, and generate an updated version. For simplicity, we will cover the *destop-full* variant. For other variants, update the filenames and rosinstall_generator arguments appropriately.

mv -i indigo-desktop-full-wet.rosinstall indigo-desktop-full-wet.rosinstall.old
rosinstall_generator desktop_full --rosdistro indigo --deps --wet-only --tar > indigo-desktop-full-wet.rosinstall

# Then, compare the new rosinstall file to the old version to see which packages will be updated:

diff -u indigo-desktop-full-wet.rosinstall indigo-desktop-full-wet.rosinstall.old

#If you're satified with these changes, incorporate the new rosinstall file into the workspace and update your workspace:

wstool merge -t src indigo-desktop-full-wet.rosinstall
wstool update -t src
#####################

#####################

# Adding released packages

# You may add additional packages to the installed ros workspace that have been released into the ros ecosystem. First, a new rosinstall file must be created including the new packages (Note, this can also be done at the initial install). For example, if we have installed ros_comm, but want to add ros_control and joystick_drivers, the command would be:

cd ~/ros_catkin_ws
rosinstall_generator ros_comm ros_control joystick_drivers --rosdistro indigo --deps --wet-only --exclude roslisp --tar > indigo-custom_ros.rosinstall

# You may keep listing as many ROS packages as you'd like separated by spaces.

# Next, update the workspace with wstool:

wstool merge -t src indigo-custom_ros.rosinstall
wstool update -t src

# After updating the workspace, you may want to run rosdep to install any new dependencies that are required:

rosdep install --from-paths src --ignore-src --rosdistro indigo -y -r --os=debian:wheezy

# Finally, now that the workspace is up to date and dependencies are satisfied, rebuild the workspace:

# I have a problem with boost libraries so I modified the code of ~/ros_catkin_ws/src/ros_comm/rosbag/src/recorder.cpp
# at line 470
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo
#####################

# From here, next lines has not been tested

#####################
# To update your workspace, first move your existing rosinstall file so that it doesn't get overwritten, and generate an updated version. For simplicity, we will cover the *destop-full* variant. For other variants, update the filenames and rosinstall_generator arguments appropriately.


mv -i indigo-desktop-full-wet.rosinstall indigo-desktop-full-wet.rosinstall.old
rosinstall_generator desktop_full --rosdistro indigo --deps --wet-only --tar > indigo-desktop-full-wet.rosinstall
# Then, compare the new rosinstall file to the old version to see which packages will be updated:


diff -u indigo-desktop-full-wet.rosinstall indigo-desktop-full-wet.rosinstall.old
# If you're satified with these changes, incorporate the new rosinstall file into the workspace and update your workspace:

wstool merge -t src indigo-desktop-full-wet.rosinstall
wstool update -t src

# Now that the workspace is up to date with the latest sources, rebuild it:


./src/catkin/bin/catkin_make_isolated --install

# If you specified the --install-space option when your workspace initially, you should specify it again when rebuilding your workspace

# Once your workspace has been rebuilt, you should source the setup files again:


source ~/ros_catkin_ws/install_isolated/setup.bash

################
# You may add additional packages to the installed ros workspace that have been released into the ros ecosystem. First, a new rosinstall file must be created including the new packages (Note, this can also be done at the initial install). For example, if we have installed ros_comm, but want to add ros_control and joystick_drivers, the command would be:


cd ~/ros_catkin_ws
rosinstall_generator ros_comm ros_control joystick_drivers --rosdistro indigo --deps --wet-only --exclude roslisp --tar > indigo-custom_ros.rosinstall
# You may keep listing as many ROS packages as you'd like separated by spaces.

# Next, update the workspace with wstool:


wstool merge -t src indigo-custom_ros.rosinstall
wstool update -t src
# After updating the workspace, you may want to run rosdep to install any new dependencies that are required:


rosdep install --from-paths src --ignore-src --rosdistro indigo -y -r --os=debian:wheezy
#  Finally, now that the workspace is up to date and dependencies are satisfied, rebuild the workspace:


sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo