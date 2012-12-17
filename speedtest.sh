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

exec 5>&2
tock=0
tick()
{
let tock++
echo -n "$tock$1" >&5
}

flush()
{
tick ${1}1
hdparm -f "$DRV" >/dev/null || die "cannot flush $DRV"
tick ${1}2
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
flush A
cryptsetup --key-file=/dev/urandom -s 256 -c "$1" create "$TST" "$DRV" || die "cannot setup $TST for $1"
flush B
cryptsetup remove "$TST" || die "cannot remove cryption of $TST"
flush C
}

ignerr()
{
"$@" 2>/dev/null
flush D
}

mytime()
{
{
{ time -p ignerr "${@:3}" >&4; } 2>&1 |
{
read x r
read x u
read x s
echo "$r real $u user $s sys $1 $2"
}
} 4>&1
}

run()
{
flush E
cryptsetup --key-file=/dev/urandom -s 256 -c "$1" create "$TST" "$DRV" || die "cannot setup $TST for $1"

trap 'cryptsetup remove "$TST" || { sleep 1; cryptsetup remove "$TST"; }' 0

flush F
mytime w "$1" dd if=/dev/zero of=/dev/mapper/"$TST" bs=1024000 status=noxfer # || die "write error"
mytime r "$1" dd if=/dev/mapper/"$TST" of=/dev/null bs=1024000 status=noxfer || die "read error"

cryptsetup remove "$TST" || die "cannot remove cryption of $TST"
trap '' 0
}

algos check
algos run 2>&1

