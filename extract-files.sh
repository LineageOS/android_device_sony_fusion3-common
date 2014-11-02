#!/bin/bash

# Use tradition sort
export LC_ALL=C

FP=$(cd ${0%/*} && pwd -P)
export VENDOR=$(basename $(dirname $FP))
export DEVICE=$(basename $FP)
export BOARDCONFIGVENDOR=false
export BOARD_VENDOR_PLATFORM=fusion3

../common/extract-files.sh $@

../common/setup-makefiles.sh

./setup-makefiles.sh
