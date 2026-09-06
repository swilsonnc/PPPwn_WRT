#!/bin/sh

cd /overlay/work/PPPwn_WRT-main
. ./settings.cfg

if [ "$dtl" != "true" ]; then
    break;
fi

INTERFACE="${dtlan}"

check_link_status() {
    ifconfig "$INTERFACE" | grep -q "RUNNING"
}

# 1. Force kill the exploit engines cleanly
killall -9 pppwn_mipsel >/dev/null 2>&1
killall -9 pppwn >/dev/null 2>&1

# 2. Reset the physical interface link to clear the PS4's stuck state
if [ "$led" != "none" ] && [ "$led" != "" ]; then
    echo "default-on" > /sys/class/leds/${led}/trigger
fi

# Main loop
while true; do
    # Check link status
    if check_link_status; then
        echo "Link $INTERFACE is UP"
    else
        echo "Link $INTERFACE is DOWN"
        break
    fi
    sleep 10
done

# Await relink
while true; do
    # Check link status
    if check_link_status; then
        echo "link up established"   
        break
    else
        echo "awaiting link up"        
    fi
    sleep 10
done

if [ "$led" != "none" ] && [ "$led" != "" ]; then
    echo "none" > /sys/class/leds/${led}/trigger
fi

echo "Link down - attempting PPPwn."
/etc/init.d/pppwn start

