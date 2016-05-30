#!/system/bin/sh
setprop gsm.radio.kickstart off

if [ $(getprop ro.boot.baseband) == "mdm" ]; then

    if [ ! -d /cache/qcks ]; then
       rm -rf /cache/qcks
       mkdir /cache/qcks
       chmod 0770 /cache/qcks
       chown system:system /cache/qcks
    fi

    for f in $(ls /cache/qcks/); do
        (ls -l /cache/qcks/$f | grep root) && rm /cache/qcks/$f;
    done

    chown system:system $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs1)
    chmod 660 $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs1)
    chown system:system $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs2)
    chmod 660 $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs2)
    chown system:system $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs3)
    chmod 660 $(realpath /dev/block/platform/msm_sdcc.1/by-name/m9kefs3)

    echo 1 > /sys/module/rmnet_usb/parameters/rmnet_data_init

    setprop gsm.radio.kickstart on
fi
