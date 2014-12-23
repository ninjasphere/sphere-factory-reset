
diff: src/factory.manifest build/factory.manifest
	diff -I ".* ./03-SDCARD/factory.env.sh" -u build/factory.manifest src/factory.manifest

build/factory.manifest: force-build
	cd build && find . -type f -exec sha1sum {} \; | grep -v factory.manifest | sort -k3,3 -t' ' > factory.manifest

force-build:

update-src: build/factory.manifest
	cp build/factory.manifest src/factory.manifest
