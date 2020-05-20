#!/system/bin/sh
echo "start log uitl"
logcat -b all|grep -v audit > /tombstones/logcat.txt &
#echo "device will reboot in 5 min."
#sleep 5m
#reboot recovery
