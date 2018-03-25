#!/bin/bash

DIRSRC=$(pwd)/src
TEMPDIR=$(pwd)/temp
MOUNTPOINT=$(pwd)/mount-point
EXFUSE=$(pwd)/fs-fuse

if [ -d $TEMPDIR ]; then
	$(rm -rf $TEMPDIR)
fi

mkdir $TEMPDIR

# Copia ficheros a directorio tmp
cp -a $DIRSRC/fuseLib.c $TEMPDIR/fuseLib.c
cp -a $DIRSRC/myFS.h $TEMPDIR/myFS.h


if [ -x $EXFUSE ]; then
	
	
	# Copia ficheros a directorio mountpoint
	cp  $DIRSRC/fuseLib.c $MOUNTPOINT/fuseLib.c
	cp  $DIRSRC/myFS.h $MOUNTPOINT/myFS.h
	
	# Falta controlar el error y mostrarlo
	../my-fsck/my-fsck ../FUSE_myFS/virtual-disk | grep "ERROR"
	
	OUT_DIFF_1COPY_FUSELIBC=$(diff $TEMPDIR/fuseLib.c $MOUNTPOINT/fuseLib.c)
	OUT_DIFF_1COPY_MYFSH=$(diff $TEMPDIR/myFS.h $MOUNTPOINT/myFS.h)
	
	# comparacion entre los diff de los ficheros por primera copia
	if [[("$OUT_DIFF_FUSELIBC" != "") || ("$OUT_DIFF_MYFSH" != "")]] ; then
      		echo "ERROR: Test incorrect, files after 1st copy are not equal"
		exit 1
	fi	
	
	truncate -o -s -1 $TEMPDIR/fuseLib.c
	truncate -o -s -1 $MOUNTPOINT/fuseLib.c
	
	# Falta controlar el error y mostrarlo
	../my-fsck/my-fsck ../FUSE_myFS/virtual-disk | grep "ERROR"
	
	OUT_DIFF_1TRUNCATE_FUSELIBC=$(diff $TEMPDIR/fuseLib.c $MOUNTPOINT/fuseLib.c)
	OUT_DIFF_1TRUNCATE_MYFSH=$(diff $TEMPDIR/myFS.h $MOUNTPOINT/myFS.h)
	
	# comparacion entre los diff de los ficheros por primera copia
	if [[("$OUT_DIFF_1TRUNCATE_FUSELIBC" != "") || ("$OUT_DIFF_1TRUNCATE_MYFSH" != "")]] ; then
      		echo "ERROR: Test incorrect, files after 1st truncate are not equal"
		exit 1
	fi	
	
	# copia de un tercer fichero al sf
	cp $DIRSRC/MyFileSystem.c $MOUNTPOINT/MyFileSystem.c
	
	../my-fsck/my-fsck ../FUSE_myFS/virtual-disk | grep "ERROR"
	
	OUT_DIFF_1COPY_MYFILESYSTEMC=$(diff $DIRSRC/MyFileSystem.c $MOUNTPOINT/MyFileSystem.c)

	# comparacion entre los diff de los ficheros por primera copia
	if [[("$OUT_DIFF_1COPY_MYFILESYSTEMC" != "")]] ; then
      		echo "ERROR: Test incorrect, third copied file not equals"
		exit 1
	fi
	
	truncate -o -s +2 $TEMPDIR/fuseLib.c
	truncate -o -s +2 $MOUNTPOINT/fuseLib.c
	
	# Falta controlar el error y mostrarlo
	../my-fsck/my-fsck ../FUSE_myFS/virtual-disk | grep "ERROR"
	
	OUT_DIFF_2TRUNCATE_FUSELIBC=$(diff $TEMPDIR/fuseLib.c $MOUNTPOINT/fuseLib.c)
	OUT_DIFF_2TRUNCATE_MYFSH=$(diff $TEMPDIR/myFS.h $MOUNTPOINT/myFS.h)
	
	# comparacion entre los diff de los ficheros por primera copia
	if [[("$OUT_DIFF_2TRUNCATE_FUSELIBC" != "") || ("$OUT_DIFF_2TRUNCATE_MYFSH" != "")]] ; then
      		echo "ERROR: Test incorrect, files after 2nd truncate are not equal"
		exit 1
	fi	
	
else
      echo "El ejecutable $EXFUSE no existe."
fi

echo "Test successfully passed !"


