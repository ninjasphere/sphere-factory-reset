DIST=~/Dropbox/ninja/factory-package

diff: src/factory.manifest build/factory.manifest
	diff -I ".* ./03-SDCARD/factory.env.sh" -u build/factory.manifest src/factory.manifest

build/factory.manifest: force-build
	cd build && find . -type f -exec sha1sum {} \; | grep -v factory.manifest | sort -k3,3 -t' ' > factory.manifest

force-build:

update-src: build/factory.manifest
	cp build/factory.manifest src/factory.manifest

update-build:
	rsync -rav src/ build/ --exclude "./03-SDCARD/factory.env.sh"

inject-password:
	test -n "$(FACTORY_PASSWORD)" || ( echo "You must define the password on the make command line." && false )
	cp src/03-SDCARD/factory.env.sh build/03-SDCARD
	sed -i -e "s/export RECOVERY_FACTORY_TEST_PASSWORD=\"{factory-test-password}/export RECOVERY_FACTORY_TEST_PASSWORD=$(FACTORY_PASSWORD)/;" build/03-SDCARD/factory.env.sh

publish: diff
	git diff HEAD
	git diff
	rsync -rav build/ $(DIST)/ --exclude "./99-OTHER/*"
