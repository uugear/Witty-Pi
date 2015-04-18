#!/bin/bash
# file: syncTime.sh
#
# This script can syncronize the time between system and RTC
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

# delay if first argument exists
if [ ! -z "$1" ]; then
  sleep $1
fi

# include utilities script in same directory
my_dir="`dirname \"$0\"`"
my_dir="`( cd \"$my_dir\" && pwd )`"
if [ -z "$my_dir" ] ; then
  exit 1
fi
. $my_dir/utilities.sh

# get RTC time
rtctime="$(get_rtc_time)"

# get system year
sysyear="$(date +%Y)"

if [[ $sysyear != *"1970"* ]]; then
  # your Raspberry Pi has ever updated time
  if [[ $rtctime == *"2000"* ]]; then
    # set system time to RTC if you never set RTC before
    system_to_rtc
  else
    # otherwise set RTC time to system
    rtc_to_system
  fi
fi
