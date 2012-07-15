#!/bin/bash

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
