#!/system/bin/sh
setprop gsm.radio.kickstart off

if [ $(getprop ro.boot.baseband) == "mdm" ]; then

    if [ ! -d /cache/qks ]; then
       rm -rf /cache/qks
       mkdir /cache/qks
       chmod 0770 /cache/qks
       chown system:system /cache/qks
    fi

    for f in $(ls /cache/qks/); do
        (ls -l /cache/qks/$f | grep root) && rm /cache/qks/$f;
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
