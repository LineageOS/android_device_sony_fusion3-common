#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Abort if device not inherited
if  [ -z "$DEVICE" ]; then
    echo "Variable DEVICE not defined, aborting..."
    exit 1
fi

# Required!
export DEVICE_COMMON=fusion3-common
export VENDOR=sony

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

ROM_ROOT="$MY_DIR"/../../..

HELPER="$ROM_ROOT"/vendor/cm/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

if [ $# -eq 0 ]; then
    SRC=adb
else
    if [ $# -eq 1 ]; then
        SRC=$1
    else
        echo "$0: bad number of arguments"
        echo ""
        echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
        echo ""
        echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
        echo "the device using adb pull."
        exit 1
    fi
fi

# Initialize the helper for common device
setup_vendor "$DEVICE_COMMON" "$VENDOR" "$ROM_ROOT" true

# Sony/Board specific blobs
extract "$MY_DIR"/proprietary-files-sony.txt "$SRC"

# QCOM common board blobs
if [ -f "$MY_DIR/proprietary-files-qc.txt" ]; then
    extract "$MY_DIR"/proprietary-files-qc.txt "$SRC"
fi

# Generate vendor makefiles
"$MY_DIR"/setup-makefiles.sh

if [ ! -z "$DEVICE_SUB_COMMON" ]; then
    # Reinitialize the helper for sub-common device
    DEVICE_COMMON=$DEVICE_SUB_COMMON
    setup_vendor "$DEVICE_COMMON" "$VENDOR" "$ROM_ROOT" true

    # Sony/Device specific blobs
    extract "$MY_DIR"/../$DEVICE_SUB_COMMON/proprietary-files-sony.txt "$SRC"

    # QCOM common device blobs
    if [ -f "$MY_DIR/../$DEVICE_SUB_COMMON/proprietary-files-qc.txt" ]; then
        extract "$MY_DIR"/../$DEVICE_SUB_COMMON/proprietary-files-qc.txt "$SRC"
    fi

    # Generate vendor makefiles
    "$MY_DIR"/../$DEVICE_SUB_COMMON/setup-makefiles.sh
fi

# Reinitialize the helper for device
setup_vendor "$DEVICE" "$VENDOR" "$ROM_ROOT"

# Sony/Device specific blobs
extract "$MY_DIR"/../$DEVICE/proprietary-files-sony.txt "$SRC"

# QCOM common device blobs
if [ -f "$MY_DIR/../$DEVICE/proprietary-files-qc.txt" ]; then
    extract "$MY_DIR"/../$DEVICE/proprietary-files-qc.txt "$SRC"
fi
