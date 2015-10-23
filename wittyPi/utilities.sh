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
  LANG=en_GB.UTF-8
  local rtctime=$(hwclock | awk '{$7=$8="";print $0}');
  unload_rtc
  echo $rtctime
}

bcd2dec()
{
  local result=$(($1/16*10+($1&0xF)))
  echo $result
}

dec2bcd()
{
  local result=$((10#$1/10*16+(10#$1%10)))
  echo $result
}

get_utc_date_time()
{
  local date=$1
  if [ $date == '??' ]; then
    date='01'
  fi
  local hour=$2
  if [ $hour == '??' ]; then
    hour='12'
  fi
  local minute=$3
  if [ $minute == '??' ]; then
    minute='00'
  fi
  local second=$4
  if [ $second == '??' ]; then
    second='00'
  fi
  local datestr=$(date +%Y-%m-)
  datestr+="$date $hour:$minute:$second"
  datestr+=$(date +%:z)
  local result=$(date -u -d "$datestr" +"%d %H:%M:%S" 2>/dev/null)
  IFS=' ' read -r date timestr <<< "$result"
  IFS=':' read -r hour minute second <<< "$timestr"
  if [ $1 == '??' ]; then
    date='??'
  fi
  if [ $2 == '??' ]; then
    hour='??'
  fi
  if [ $3 == '??' ]; then
    minute='??'
  fi
  if [ $4 == '??' ]; then
    second='??'
  fi
  echo "$date $hour:$minute:$second"
}

get_local_date_time()
{
  local when=$1
  IFS=' ' read -r date timestr <<< "$when"
  IFS=':' read -r hour minute second <<< "$timestr"
  local bk_date=$date
  local bk_hour=$hour
  local bk_min=$minute
  local bk_sec=$second
  if [ $date == '??' ]; then
    date='01'
  fi
  if [ $hour == '??' ]; then
    hour='12'
  fi
  if [ $minute == '??' ]; then
    minute='00'
  fi
  if [ $second == '??' ]; then
    second='00'
  fi
  local datestr=$(date +%Y-%m-)
  datestr+="$date $hour:$minute:$second UTC"
  local result=$(date -d "$datestr" +"%d %H:%M:%S" 2>/dev/null)
  IFS=' ' read -r date timestr <<< "$result"
  IFS=':' read -r hour minute second <<< "$timestr"
  if [ $bk_date == '??' ]; then
    date='??'
  fi
  if [ $bk_hour == '??' ]; then
    hour='??'
  fi
  if [ $bk_min == '??' ]; then
    minute='??'
  fi
  if [ $bk_sec == '??' ]; then
    second='??'
  fi
  echo "$date $hour:$minute:$second"
}

get_startup_time()
{
  sec=$(bcd2dec $(i2cget -y 0x01 0x68 0x07))
  if [ $sec == '128' ]; then
    sec='??'
  fi
  min=$(bcd2dec $(i2cget -y 0x01 0x68 0x08))
  if [ $min == '128' ]; then
    min='??'
  fi
  hour=$(bcd2dec $(i2cget -y 0x01 0x68 0x09))
  if [ $hour == '128' ]; then
    hour='??'
  fi
  date=$(bcd2dec $(i2cget -y 0x01 0x68 0x0A))
  if [ $date == '128' ]; then
    date='??'
  fi
  echo "$date $hour:$min:$sec"
}

set_startup_time()
{
  i2cset -y 0x01 0x68 0x0E 0x07
  if [ $4 == '??' ]; then
    sec=$(dec2bcd '128')
  else
    sec=$(dec2bcd $4)
  fi
  i2cset -y 0x01 0x68 0x07 $sec
  if [ $3 == '??' ]; then
    min=$(dec2bcd '128')
  else
    min=$(dec2bcd $3)
  fi
  i2cset -y 0x01 0x68 0x08 $min
  if [ $2 == '??' ]; then
    hour=$(dec2bcd '128')
  else
    hour=$(dec2bcd $2)
  fi
  i2cset -y 0x01 0x68 0x09 $hour
  if [ $1 == '??' ]; then
    date=$(dec2bcd '128')
  else
    date=$(dec2bcd $1)
  fi
  i2cset -y 0x01 0x68 0x0A $date
}

clear_startup_time()
{
  i2cset -y 0x01 0x68 0x07 0x00
  i2cset -y 0x01 0x68 0x08 0x00
  i2cset -y 0x01 0x68 0x09 0x00
  i2cset -y 0x01 0x68 0x0A 0x00
}

get_shutdown_time()
{
  min=$(bcd2dec $(i2cget -y 0x01 0x68 0x0B))
  if [ $min == '128' ]; then
    min='??'
  fi
  hour=$(bcd2dec $(i2cget -y 0x01 0x68 0x0C))
  if [ $hour == '128' ]; then
    hour='??'
  fi
  date=$(bcd2dec $(i2cget -y 0x01 0x68 0x0D))
  if [ $date == '128' ]; then
    date='??'
  fi
  echo "$date $hour:$min:00"
}

set_shutdown_time()
{
  i2cset -y 0x01 0x68 0x0E 0x07
  if [ $3 == '??' ]; then
    min=$(dec2bcd '128')
  else
    min=$(dec2bcd $3)
  fi
  i2cset -y 0x01 0x68 0x0B $min
  if [ $2 == '??' ]; then
    hour=$(dec2bcd '128')
  else
    hour=$(dec2bcd $2)
  fi
  i2cset -y 0x01 0x68 0x0C $hour
  if [ $1 == '??' ]; then
    date=$(dec2bcd '128')
  else
    date=$(dec2bcd $1)
  fi
  i2cset -y 0x01 0x68 0x0D $date
}

clear_shutdown_time()
{
  i2cset -y 0x01 0x68 0x0B 0x00
  i2cset -y 0x01 0x68 0x0C 0x00
  i2cset -y 0x01 0x68 0x0D 0x00
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

trim()
{
  local result=$(echo "$1" | sed -n '1h;1!H;${;g;s/^[ \t]*//g;s/[ \t]*$//g;p;}')
  echo $result
}

current_timestamp()
{
  load_rtc
  unset LANG
  local rtctime=$(hwclock | awk '{$6=$7="";print $0}');
  unload_rtc
  local rtctimestamp=$(date -d "$rtctime" +%s)
  if [ "$rtctimestamp" == "" ] ; then
    echo $(date +%s)
  else
    echo $rtctimestamp
  fi
}
