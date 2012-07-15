#!/bin/bash
#
# This Works is placed under the terms of the Copyright Less License,
# see file COPYRIGHT.CLL.  USE AT OWN RISK, ABSOLUTELY NO WARRANTY.

die()
{
echo "ERROR: $*" >&2
exit 1
}

[ 0 = "`id -u`" ] || die "must be root"

for need in cryptsetup hdparm dd
do
	which "$need" >/dev/null || die "please install $need"
done

DRV="$1"
TST=speedtest-tmp
INP=speedtest.algos

flush()
{
hdparm -f "$DRV" >/dev/null || die "cannot flush $DRV"
}

algos()
{
while read -u3 algo
do
	case "$algo" in
	\#*)	continue;;
	'')	continue;;
	esac
	"$@" "$algo"
done 3<"$INP"
}

check()
{
cryptsetup --key-file=/dev/urandom -s 256 -c "$1" create "$TST" "$DRV" || die "cannot setup $TST for $1"
cryptsetup remove "$TST" || die "cannot remove cryption of $TST"
}

run()
{
flush
cryptsetup --key-file=/dev/urandom -s 256 -c "$1" create "$TST" "$DRV" || die "cannot setup $TST for $1"

trap 'cryptsetup remove "$TST" || { sleep 1; cryptsetup remove "$TST"; }' 0

flush
echo "running: write $1"
time dd if=/dev/zero of=/dev/mapper/"$TST" bs=1024000 # || die "write error"
flush
echo "was for: write $1"
echo "running: read  $1"
time dd if=/dev/mapper/"$TST" of=/dev/null bs=1024000 || die "read error"
echo "was for: read  $1"
flush

cryptsetup remove "$TST" || die "cannot remove cryption of $TST"
trap '' 0
}

algos check
algos run 2>&1

