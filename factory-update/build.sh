#!/bin/bash

die() {
	echo "$*" 2>&1
	exit 1
}

download() {
	rc=0
	mkdir -p .cache
	cat usb-packages.manifest.json | jq -r '.packages[]|.file+" "+.["url-prefix"]+" "+.sha1' | while read file urlPrefix sha1; do
		(
			if test -f ".cache/$file"; then
				if test "$(openssl sha1 < ".cache/$file")" != "$sha1"; then
					rm -f ".cache/$file" || die "failed to remove corrupt file: $file"
				fi
			fi
			if ! test -f ".cache/$file"; then
				curl ${CURL_OPTS} -s -o ".cache/$file" "$urlPrefix/$file" || die "failed to download: $file"
			fi
			test "$(openssl sha1 < ".cache/$file")" = "$sha1" || die "failed to verify downloaded file: $file: actual $(openssl sha1 < ".cache/$file") not equal to expected $sha1"
		) || rc=1
		test $rc -eq 0
	done || die "failed"
}

filter-packages() {
	local pattern=${1:-.}
	sed -n "s/^Filename: //p;s/^SHA1: //p" | while read f; do
		read sha1
		echo $f $sha1
	done | grep "$pattern" | while read f sha1; do
		b=$(basename "$f")
		d=$(dirname "$f")
		echo "{\"file\": \"$b\", \"url-prefix\": \"https://s3.amazonaws.com/ninjablocks-apt-repo/$d\", \"sha1\": \"$sha1\"}"
	done | jq .
}

main() {
	"$@"
}

main "$@"