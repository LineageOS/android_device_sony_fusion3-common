#!/system/bin/sh

FIRSTBOOTDONE=`/system/bin/getprop persist.msm_therm.firstbootdone`

if [ "${FIRSTBOOTDONE}" = "1" ]; then
	while true
	do
		BOOTCOMPLETE=`/system/bin/getprop sys.boot_completed`
		if [ "${BOOTCOMPLETE}" = "1" ]; then
			break
		fi
		sleep 1
	done
fi

echo "N" > /sys/module/msm_thermal/parameters/enabled
echo 0 > /sys/module/msm_thermal/core_control/cpus_offlined
/system/bin/setprop persist.msm_therm.firstbootdone 1
