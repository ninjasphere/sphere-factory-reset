#!/usr/bin/env bash

die() {
	echo "$*" 1>&2
	exit 1
}

repack() {
	deb=$1

	test -f "$deb" || die "usage: repack {.deb} file"

	package=$(basename $deb .deb)
	work=/tmp/ipkg.work.$$
	mkdir -p "$work"

	trap "rm -rf $work" EXIT

	cp $deb $work &&
	pushd "$work" &&
	ar x $(basename $deb) &&
	find . &&
	xz -d ./data.tar.xz &&
	gzip data.tar &&
	tar -cvzf ${package}.ipk ./debian-binary ./data.tar.gz ./control.tar.gz &&
	popd &&
	cp $work/${package}.ipk . &&
	echo $(pwd)/${package}.ipk
}

main() {
	case "$1" in
	repack)
		shift 1
		repack "$@"
	;;
	*)
		die "usage: repack .deb"
	;;
	esac
}

main "$@"
