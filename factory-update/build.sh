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
					rm -f "$file" || die "failed to remove corrupt file: $file"
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

main() {
	"$@"
}

main "$@"