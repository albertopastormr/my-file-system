#!/bin/bash

DIRSRC=$(pwd)/src
TEMPDIR=$(pwd)/temp
MOUNTPOINT=$(pwd)/mountpoint
EXFUSE=$(pwd)/fs-fuse

if [ -d $TEMPDIR ]; then
	$(rm -rf $TEMPDIR)
fi

mkdir $TEMPDIR

cp -a $DIRSRC/fuseLib.c $TEMPDIR/fuseLib.c
cp -a $DIRSRC/myFS.h $TEMPDIR/myFS.h

fusermount -u mountpoint

if [ -d $MOUNTPOINT ]; then
	$(rm -rf $MOUNTPOINT)
fi

mkdir $MOUNTPOINT


if [ -x $EXFUSE ]; then

	./fs-fuse -t 2097152 -a virtual-disk -f '-d -s mountpoint' &

	cp -a $DIRSRC/fuseLib.c $MOUNTPOINT/fuseLib.c
	cp -a $DIRSRC/myFS.h $MOUNTPOINT/myFS.h
	
	# Falta controlar el error y mostrarlo
	./my-fsck virtual-disk | grep "ERROR"
	
	OUT_DIFF_FUSELIBC=diff $TEMPDIR/fuseLib.c $MOUNTPOINT/fuseLib.c
	OUT_DIFF_MYFSH=diff $TEMPDIR/myFS.h $MOUNTPOINT/myFS.h
	
	if [[("$OUT_DIFF_FUSELIBC" != "") || ("$OUT_DIFF_MYFSH" != "")]] ; then
      		echo "ERROR: Test incorrect:  doesn't match"
		exit 1
	fi	
	
	truncate -o -s -1 $TEMPDIR/fuseLib.c
	truncate -o -s -1 $TEMPDIR/fuseLib.c


else
      echo "El ejecutable $EXFUSE no existe."
fi


