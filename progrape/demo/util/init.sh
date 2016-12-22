#! /bin/sh
# Time-stamp: <2006-11-22 17:38:27 hamada>
# Copyright (c) 2006 by Tsuyoshi Hamada, All rights reserved.
#
# init script for PGR & PROGRAPE-4 (for developers)
#

rm -rf /tmp/*
ln -s /usr/local/src/Xilinx.8_1_03i_lin /tmp/Xilinx
ln -s /usr/local/src/intel_cc_80 /tmp/intel_cc_80
ln -s /usr/local/src/package.20060613 /tmp/pgr
ln -s /usr/local/src/progrape /tmp/progrape
cd /pciDriver/src/driver/; ./insmod.sh

cd /tmp/progrape/driver;  make load


umount /mnt/ram
rm -rf /mnt/ram
mkdir /mnt/ram
mke2fs /dev/ram0
mount -t ext2 /dev/ram0 /mnt/ram
chmod -R 777 /mnt/ram

cp /usr/local/bin/xxx.log /mnt/ram
chmod -R 777 /mnt/ram


