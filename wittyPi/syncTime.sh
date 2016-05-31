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


# if RTC presents
if $(is_rtc_connected) ; then
  log 'Synchronizing time between system and Witty Pi...'

  # get RTC time
  rtctime="$(get_rtc_time)"

  if $(has_internet) ; then
    if [[ $rtctime != *"1999"* ]] && [[ $rtctime != *"2000"* ]]; then
      # if RTC time is OK, write RTC time to system first
      rtc_to_system
    fi
    # now take new time from NTP
    log 'Internet detected, apply NTP time to system and Witty Pi...'
    force_ntp_update
    system_to_rtc
  else
    # get RTC time
    rtctime="$(get_rtc_time)"

    # get system year
    sysyear="$(date +%Y)"

    if [[ $rtctime == *"1999"* ]] || [[ $rtctime == *"2000"* ]]; then
      # if you never set RTC time before
      log 'RTC time has not been set before (stays in year 1999/2000).'
      if [[ $sysyear != *"1970"* ]]; then
        # your Raspberry Pi has a decent time
        system_to_rtc
      else
        log 'Neither system nor Witty Pi contains correct time.'
      fi
    else
      # RTC time seems OK, write RTC time to system
      log 'RTC contains newer time.'
      rtc_to_system
    fi
  fi
else
  log 'Witty Pi is not connected, skip synchronizing time...'
fi
