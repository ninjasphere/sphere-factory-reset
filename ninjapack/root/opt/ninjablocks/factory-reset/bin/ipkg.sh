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
	gzip -d ./control.tar.gz &&
	mkdir data &&
	mkdir control &&
	tar -C data -xf data.tar &&
	tar -C control -xf control.tar &&
	unpack=$(RECOVERY_UNPACK_TMP_DIR=/tmp data/opt/ninjablocks/bin/recovery.sh unpack) &&
	mkdir data/opt/ninjablocks/factory-reset/ &&
	rsync -rav $unpack/ data/opt/ninjablocks/factory-reset/ &&
	( cd data ; find . -type f | while read f; do
		f=${f#./}
		md5sum "$f"
	done ) > control/md5sums &&
	sed -i "s/^Architecture:.*/Architecture: varsomam33/" control/control &&
	tar -C data -czf data.tar.gz . &&
	tar -C control -czf control.tar.gz . &&
	ar r ${package}.ipk ./debian-binary ./data.tar.gz ./control.tar.gz &&
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
