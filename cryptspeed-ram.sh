#!/bin/bash

DIR=
DEV=
cleanup()
{
[ -z "$DEV" ] || losetup -d "$DEV"
DEV=
[ -z "$DIR" ] && return
umount "$DIR"
rmdir "$DIR"
DIR=
}

setup_dev()
{
sz="${1:-2048}"

DIR="`mktemp -d /tmp/cryptspeed.XXXXXX`" || die mktemp failed
mount -t ramfs -o size="$szM" ramfs "$DIR" || die "cannot mount ramfs into $DIR, machine must have more than 2 GB of free RAM!"

dd if=/dev/zero of="$DIR/crypttest.tmp" bs=1048576 count="$sz" 2>/dev/null || die "cannot create temporary file of size $sz MB"
DEV="`losetup --show -f "$DIR/crypttest.tmp"`" || die "cannot use losetup to setup loop device"
}

die()
{
cleanup
echo "PROBLEM: $*" >&2
exit 1
}

./setupallcryptos.sh

trap cleanup 0
setup_dev "$@"
./speedtest.sh "$DEV"

