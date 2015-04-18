#!/bin/bash
# file: daemon.sh
#
# This script should be auto started, to support WittyPi hardware
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

# disable square wave and enable alarm B
i2cset -y 0x01 0x68 0x0E 0x07

# clear alarm flags
byte_F=$(i2cget -y 0x01 0x68 0x0F)
byte_F=$(($byte_F&0xFC))
i2cset -y 0x01 0x68 0x0F $byte_F

# wait for GPIO-4 (wiringPi pin 7) falling, or alarm B
gpio wfi 7 falling

echo "Halting all processes and then shutdown Raspberry Pi..."

# restore GPIO-4
gpio mode 7 in
gpio mode 7 up

# clear alarm flags
byte_F=$(i2cget -y 0x01 0x68 0x0F)
byte_F=$(($byte_F&0xFC))
i2cset -y 0x01 0x68 0x0F $byte_F

# only enable alarm A
i2cset -y 0x01 0x68 0x0E 0x05

# light the white LED
gpio mode 0 out
gpio write 0 1

# halt everything and shutdown
shutdown -h now
