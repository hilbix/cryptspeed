Testing the crypt speed of Linux Kernel

I was puzzled how fast different algorithms are using dm-crypt.
Therefor this script.

This test must be run as root.  **Note that your machine must have enough free RAM.**  The default needs 3 GB RAM or more.


For the impatient
=================

Just run a test on how fast the algorithms listed in `speedtest.algos` are:
```bash
./cryptspeed-ram.sh [MB] | sort -n
```
`MB` defaults to 2048 and is the size of the encrypted datablock to test.  Note that the default (2 GB) may take several minutes to encrypt, so the complete test can take an hour.  Killing may take some time, as the kernel delays until all flushs are done.

See file `EXAMPLE.out` for example output (before sort -n).


Usage
=====

Here are in-detail how to run this.  For your convenience the ramfs/loop variant is done in cryptspeed-ram.sh


Preparation
-----------

Define which algorithms to test:
```bash
vim speedtest.algos
```

Setup all the crypto algorithms in the kernel:
```bash
./setupallcryptos.sh
```

Either create a test device to use with DM-Crypt
```bash
lvcreate -n scratch-crypttest -L 2G vg_main
```
or create a RAMDISK
```bash
mkdir -p /mnt/ramfs
mount -t ramfs -o size=2G ramfs /mnt/ramfs
dd if=/dev/zero of=/mnt/ramfs/tmpfile2G bs=1048576 count=2048
losetup --show -f /mnt/ramfs/tmpfile2G
```
This device will be used as the crypt target drive.


Run the tests
-------------

```bash
./speedtest.sh /dev/mapper/vg_main-scratch--crypttest
or
./speedtest.sh /dev/loopX
```


Cleanup
-------

Getting rid of the test drives:
```bash
lvchange -an /dev/mapper/vg_main-scratch--crypttest
lvremove /dev/mapper/vg_main-scratch--crypttest
```
or
```bash
losetup -d /dev/loopX
umount /mnt/ramfs
```


Latest changes
==============

- The timing information might differ a bit from the previous one, as the time is done differently
- cryptspeed-ram.sh added
- Output changed to be more tabular


License
=======

This Works is placed under the terms of the Copyright Less License,
see file COPYRIGHT.CLL.  USE AT OWN RISK, ABSOLUTELY NO WARRANTY.

Note: CLL basically is PD, except that it forbids to add any Copyright.
