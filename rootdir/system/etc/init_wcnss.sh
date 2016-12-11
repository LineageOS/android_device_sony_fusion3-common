#!/system/bin/sh

# [   13.460479] init: write_file: Unable to write to '/dev/wcnss_wlanw': Bad address
# The file should be just opened and closed
# drivers/net/wireless/wcnss/wcnss_wlan.c:
# /* first (valid) write to this device should be 4 bytes cal file size */

cat <<EOF >> /dev/wcnss_wlan
EOF
