Testing the crypt speed of Linux Kernel

I was puzzled how fast different algorithms are using dm-crypt.
Therefor this script.

Usage
=====

Setup some test device to use with DM-Crypt.  This will be mapped to some crypt target drive.

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

Define which algorithms to test:
```bash
vim speedtest.algos
```

Setup all the crypto algorithms in the kernel:
```bash
./setupallcryptos.sh
```

Run the tests:
```bash
./speedtest.sh /dev/mapper/vg_main-scratch--crypttest
or
./speedtest.sh /dev/loopX
```

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

License
-------

This Works is placed under the terms of the Copyright Less License,
see file COPYRIGHT.CLL.  USE AT OWN RISK, ABSOLUTELY NO WARRANTY.

Note: CLL basically is PD, except that it forbids to add any Copyright.
