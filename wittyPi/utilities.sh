#!/bin/bash
# file: utilities.sh
#
# This script provides some useful utility functions
#

load_rtc()
{
  modprobe rtc-ds1307
  sh -c 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device'
}

unload_rtc()
{
  rmmod rtc-ds1307
}

get_rtc_time()
{
  load_rtc
  local rtctime+="$(hwclock -r)"
  unload_rtc
  echo "$rtctime"
}

bcd2dec()
{
  local result=$(($1/16*10+($1&0xF)))
  echo "$result"
}

dec2bcd()
{
  local result=$((10#$1/10*16+(10#$1%10)))
  echo "$result"
}

get_utc_date_time()
{
  local datestr=$(date +%Y-%m-)
  datestr+="$1"
  datestr+=$(date +%:z)
  local result=$(date -u -d "$datestr" +"%d %H:%M:%S" 2>/dev/null)
  echo "$result"
}

get_local_date_time()
{
  local datestr=$(date +%Y-%m-)
  datestr+="$1 UTC"
  local result=$(date -d "$datestr" +"%d %H:%M:%S" 2>/dev/null)
  echo "$result"
}

get_startup_time()
{
  sec=$(bcd2dec $(i2cget -y 0x01 0x68 0x07))
  min=$(bcd2dec $(i2cget -y 0x01 0x68 0x08))
  hour=$(bcd2dec $(i2cget -y 0x01 0x68 0x09))
  date=$(bcd2dec $(i2cget -y 0x01 0x68 0x0A))
  echo "$date $hour:$min:$sec"
}

set_startup_time()
{
  i2cset -y 0x01 0x68 0x0E 0x07
  sec=$(dec2bcd $4)
  i2cset -y 0x01 0x68 0x07 $sec
  min=$(dec2bcd $3)
  i2cset -y 0x01 0x68 0x08 $min
  hour=$(dec2bcd $2)
  i2cset -y 0x01 0x68 0x09 $hour
  date=$(dec2bcd $1)
  i2cset -y 0x01 0x68 0x0A $date
}

get_shutdown_time()
{
  min=$(bcd2dec $(i2cget -y 0x01 0x68 0x0B))
  hour=$(bcd2dec $(i2cget -y 0x01 0x68 0x0C))
  date=$(bcd2dec $(i2cget -y 0x01 0x68 0x0D))
  echo "$date $hour:$min"
}

set_shutdown_time()
{
  i2cset -y 0x01 0x68 0x0E 0x07
  min=$(dec2bcd $3)
  i2cset -y 0x01 0x68 0x0B $min
  hour=$(dec2bcd $2)
  i2cset -y 0x01 0x68 0x0C $hour
  date=$(dec2bcd $1)
  i2cset -y 0x01 0x68 0x0D $date
}

system_to_rtc()
{
  echo "  Writing system time to RTC..."
  load_rtc
  hwclock -w
  unload_rtc
  echo "  Done :-)"
}

rtc_to_system()
{
  echo "  Writing RTC time to system..."
  load_rtc
  hwclock -s
  unload_rtc
  echo "  Done :-)"
}
