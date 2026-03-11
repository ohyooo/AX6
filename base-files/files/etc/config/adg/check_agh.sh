#!/bin/sh

# crontab -e
# * * * * * /bin/sh /etc/config/adg/check_agh.sh

# logread | grep agh-watchdog
if ! pgrep -f "AdGuardHome" > /dev/null; then
    logger -t agh-watchdog "AdGuardHome not running, restarting..."

    /usr/bin/AdGuardHome --work-dir /etc/config/adg --config /etc/config/adg/AdGuardHome.yaml >/dev/null 2>&1 &
fi

# logread | grep mosdns-watchdog
if ! pgrep -f "mosdns" > /dev/null; then
    logger -t mosdns-watchdog "mosdns not running, restarting..."

    /usr/bin/mosdns service start >/dev/null 2>&1
fi
