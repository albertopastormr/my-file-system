#!/bin/bash
MOUNTPOINT=$(pwd)/mount-point

fusermount -u mount-point 

if [ -d $MOUNTPOINT ]; then
	$(rm -rf $MOUNTPOINT)
fi

mkdir $MOUNTPOINT

./fs-fuse -t 2097152 -a virtual-disk -f '-s -d mount-point'
