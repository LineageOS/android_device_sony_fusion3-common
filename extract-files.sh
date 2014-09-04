#!/bin/bash

export DEVICE=${PWD##*/}
export BOARDCONFIGVENDOR=false
export BOARD_VENDOR_PLATFORM=fusion3

../common/extract-files.sh $@

../common/setup-makefiles.sh
./setup-makefiles.sh
