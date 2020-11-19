#!/bin/bash

DISK=`fdisk -l | grep -o /dev/*da | head -1`
PART=$DISK"3"
VGNAME=`lvdisplay | grep "VG Name" | awk ' ''{print $3}'`
LVNAME=`lvdisplay | grep "LV Name" | awk ' ''{print $3}'`

echo "Creating new partition..."
echo "n
p
3


t
3
8e
w
" | fdisk $DISK
sleep 10s

echo "Syncing disk..."
partprobe
sleep 20s

echo "Creating PV..."
pvcreate $PART
sleep 10s

echo "Extending VG..."
vgextend $VGNAME $PART
sleep 10s

echo "Extending LV..."
lvextend -l +100%FREE /dev/mapper/$VGNAME-$LVNAME
sleep 10s

echo "Resizing volume..."
resize2fs -p /dev/mapper/$VGNAME-$LVNAME
sleep 6s

echo "Done! Please restart your server."
