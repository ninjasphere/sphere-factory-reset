#!/usr/bin/env bash

#
# Checks that the first X bytes of /dev/mtdN have an md5sum that matches md5sum /etc/firmware-versions/mtdN-X.md5
#
# Excludes mtd6, mtd7 and mtd9 since these partitions are known to be different from the checksum.
#
# Used during factory flashing process to detect bad blocks outside of the UBI managed partition (mtd9).
#
die() {
	echo "$*" 1>&2
	exit 1
}

md5sum() {
	openssl md5 | cut -f2 -d' '
}

main() {
	rc=0
	find /etc/firmware-versions -maxdepth 1 -mindepth 1 -type f -name 'mtd*.md5' | egrep -v "mtd9|mtd6|mtd7" | while read f; do
		file=$(basename "$f" .md5)
		check=$(cat "$f")
		set -- ${file/-/ }
		device=$1
		size=$2
		if test -c /dev/$device; then
			if md5=$(dd if=/dev/$device bs=$size count=1 2>/dev/null | md5sum) && test "$md5" = "$check"; then
				echo "$f...ok" 1>&2
			else
				echo "$f...failed '$md5' != '$check'" 1>&2
				rc=1
			fi
		fi
		test $rc -eq 0
	done || die "failed"
	echo "ok" 1>&2
	true
}

main "$@"