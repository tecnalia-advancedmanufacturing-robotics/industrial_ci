#!/bin/bash

# Copyright (c) 2015, Isaac I. Y. Saito
# Copyright (c) 2017, Mathias Lüdtke
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ ! "$CATKIN_PARALLEL_JOBS" ]; then export CATKIN_PARALLEL_JOBS="-p4"; fi
if [ ! "$CATKIN_PARALLEL_TEST_JOBS" ]; then export CATKIN_PARALLEL_TEST_JOBS="$CATKIN_PARALLEL_JOBS"; fi
if [ ! "$ROS_PARALLEL_JOBS" ]; then export ROS_PARALLEL_JOBS="-j8"; fi
if [ ! "$ROS_PARALLEL_TEST_JOBS" ]; then export ROS_PARALLEL_TEST_JOBS="$ROS_PARALLEL_JOBS"; fi
# .rosintall file name
if [ ! "$ROSINSTALL_FILENAME" ]; then export ROSINSTALL_FILENAME=".travis.rosinstall"; fi
# For apt key stores
if [ ! "$APTKEY_STORE_HTTPS" ]; then export APTKEY_STORE_HTTPS="https://raw.githubusercontent.com/ros/rosdistro/master/ros.key"; fi
if [ ! "$APTKEY_STORE_SKS" ]; then export APTKEY_STORE_SKS="hkp://ha.pool.sks-keyservers.net"; fi  # Export a variable for SKS URL for break-testing purpose.
if [ ! "$HASHKEY_SKS" ]; then export HASHKEY_SKS="0xB01FA116"; fi
if [ "$USE_DEB" ]; then  # USE_DEB is deprecated. See https://github.com/ros-industrial/industrial_ci/pull/47#discussion_r64882878 for the discussion.
    if [ "$USE_DEB" != "true" ]; then export UPSTREAM_WORKSPACE="file";
    else export UPSTREAM_WORKSPACE="debian";
    fi
fi
if [ ! "$UPSTREAM_WORKSPACE" ]; then export UPSTREAM_WORKSPACE="debian"; fi

# variables in docker.env without default will be exported with empty string
# this might break the build, e.g. for Makefile which rely on these variables
if [ -z "${CC}" ]; then unset CC; fi
if [ -z "${CXX}" ]; then unset CXX; fi

# If not specified, use ROS Shadow repository http://wiki.ros.org/ShadowRepository
if [ ! "$ROS_REPOSITORY_PATH" ]; then
    case "${ROS_REPO:-ros-shadow-fixed}" in
    "building")
        ROS_REPOSITORY_PATH="http://repositories.ros.org/ubuntu/building/"
        ;;
    "ros"|"main")
        ROS_REPOSITORY_PATH="http://packages.ros.org/ros/ubuntu"
        ;;
    "ros-shadow-fixed"|"testing")
        ROS_REPOSITORY_PATH="http://packages.ros.org/ros-shadow-fixed/ubuntu"
        ;;
    *)
        error "ROS repo '$ROS_REPO' is not supported"
        ;;
    esac
fi

export OS_CODE_NAME
export OS_NAME
export DOCKER_BASE_IMAGE

# exit with error if OS_NAME is set, but OS_CODE_NAME is not
if [ -n "$OS_NAME" ] && [ -z "$OS_CODE_NAME" ]; then
    error "please specify OS_CODE_NAME"
fi

if [ -n "$UBUNTU_OS_CODE_NAME" ]; then # for backward-compatibility
    OS_CODE_NAME=$UBUNTU_OS_CODE_NAME
    OS_NAME=ubuntu
fi

if [ -n "$DOCKER_BASE_IMAGE" ]; then
    # try to guess OS from default image scheme
    OS_CODE_NAME=${OS_CODE_NAME:-${DOCKER_BASE_IMAGE##*:}} # use tag
    OS_NAME=${OS_NAME:-${DOCKER_BASE_IMAGE%%:*}} # use repo
else
    if [ -z "$OS_CODE_NAME" ]; then
        case "$ROS_DISTRO" in
        "hydro")
            OS_CODE_NAME="precise"
            ;;
        "indigo"|"jade")
            OS_CODE_NAME="trusty"
            ;;
        "kinetic"|"lunar")
            OS_CODE_NAME="xenial"
            ;;
        *)
            error "ROS distro '$ROS_DISTRO' is not supported"
            ;;
        esac
        OS_NAME=ubuntu
    fi
    DOCKER_BASE_IMAGE="$OS_NAME:$OS_CODE_NAME" # scheme works for all supported OS images
fi


export TERM=${TERM:-dumb}
