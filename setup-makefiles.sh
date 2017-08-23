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
export INITIAL_COPYRIGHT_YEAR=2013

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

# Initialize the helper for common device
setup_vendor "$DEVICE_COMMON" "$VENDOR" "$LINEAGE_ROOT" true

# Copyright headers and common guards
write_headers "dogo odin pollux pollux_windy yuga"

# Sony/Board specific blobs
write_makefiles "$MY_DIR"/proprietary-files-sony.txt

# QCOM common board blobs
if [ -f "$MY_DIR/proprietary-files-qc.txt" ]; then
    printf '\n' >> "$PRODUCTMK"
    write_makefiles "$MY_DIR"/proprietary-files-qc.txt
fi

write_footers

if [ ! -z "$DEVICE_SUB_COMMON" ]; then
    # Reinitialize the helper for sub-common device
    DEVICE_COMMON=$DEVICE_SUB_COMMON
    setup_vendor "$DEVICE_COMMON" "$VENDOR" "$LINEAGE_ROOT" true

    # Copyright headers and guards
    write_headers "pollux pollux_windy"

    # Sony/Device specific blobs
    write_makefiles "$MY_DIR"/../$DEVICE_SUB_COMMON/proprietary-files-sony.txt

    # QCOM common device blobs
    if [ -f "$MY_DIR/../$DEVICE_SUB_COMMON/proprietary-files-qc.txt" ]; then
        printf '\n' >> "$PRODUCTMK"
        write_makefiles "$MY_DIR"/../$DEVICE_SUB_COMMON/proprietary-files-qc.txt
    fi

    write_footers
fi

# Reinitialize the helper for device
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT"

# Copyright headers and guards
write_headers

# Sony/Device specific blobs
write_makefiles "$MY_DIR"/../$DEVICE/proprietary-files-sony.txt

# QCOM common device blobs
if [ -f "$MY_DIR/../$DEVICE/proprietary-files-qc.txt" ]; then
    printf '\n' >> "$PRODUCTMK"
    write_makefiles "$MY_DIR"/../$DEVICE/proprietary-files-qc.txt
fi

# Vendor BoardConfig variables
printf 'USE_CAMERA_STUB := false\n' >> "$BOARDMK"

write_footers
