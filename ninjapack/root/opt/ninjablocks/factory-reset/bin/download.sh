#!/bin/bash

die() {
	echo "$*" 1>&2
	exit 1
}

usage() {
	cat <<EOF
download {level}
EOF
}

file() {
	local type=$1
	local level=$2
	local suffix=$3

	case "$type" in
	prefix)
		echo https://firmware.sphere.ninja/latest/
	;;
	stem)
		echo ubuntu_armhf_trusty_norelease_sphere-
	;;
	stem+level)
		echo $(file stem)${level}-recovery.
	;;
	manifest)
		echo $(file stem)${level}.manifest
	;;
	stem+level+suffix)
		echo $(file stem)${level}-recovery.${suffix}
	;;
	esac
}

download() {
	local level=$1
	test -n "$level" || die "usage: download level"
	manifest=$(file manifest $level)
	curl -f -sO $(file prefix)$manifest || die "failed to download manifest"
	rc=0
	cat $manifest | grep $(file stem+level $level) | while read sha1 file; do
		echo -n "$file..."
		if ! test -f "$file" ||
			test "$(openssl sha1 < "$file")" != "$sha1"; then
			echo -n "downloading..."
			if	curl -f -sO $(file prefix)$file &&
				test "$(openssl sha1 < "$file")" == "$sha1"; then
				echo "ok"
			else
				echo "failed"
			fi
		else
			echo "ok"
		fi
		test $rc -eq 0
	done 1>&2 || die "download failed."
}

main() {
	cmd=$1
	shift 1
	case "$cmd" in
	download|file)
		"$cmd" "$@"
	;;
	*)
		usage
	;;
	esac
}

main "$@"