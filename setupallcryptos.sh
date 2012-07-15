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

for a in . . . . . 
do
	find /lib/modules/`uname -r`/kernel/crypto -name '*.ko' | xargs -n1 insmod 2>/dev/null
done
