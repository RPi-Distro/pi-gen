#!/bin/sh
### BEGIN INIT INFO
# Provides:          raspi-config
# Required-Start: udev mountkernfs $remote_fs
# Required-Stop:
# Default-Start: S 2 3 4 5
# Default-Stop:
# Short-Description: Switch to performance cpu governor (unless shift key is pressed)
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Checking if shift key is held down"
    if [ -x /usr/sbin/thd ] && timeout 1 thd --dump /dev/input/event* | grep -q "LEFTSHIFT\|RIGHTSHIFT"; then
      printf " Yes. Not enabling performance scaling governor"
      log_end_msg 0
    else
      printf " No. Switching to performance scaling governor"
      SYS_CPUFREQ_GOVERNOR=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      if [ -e $SYS_CPUFREQ_GOVERNOR ]; then
        echo "performance" > $SYS_CPUFREQ_GOVERNOR
      fi
      log_end_msg 0
    fi
    ;;
  stop)
    ;;
  restart)
    ;;
  force-reload)
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
