
VERSION := $(shell jq -r '.version' usb-packages.manifest.json)
FILES := $(shell jq -r '.packages[].file' usb-packages.manifest.json)

all: clean build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip

dist: all
	SHA1=$$(sha1sum build/usb-packages.manifest | cut -c1-8) && \
	cp build/*$${VERSION}-$${SHA1}* dist

build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip: files build/usb-packages.manifest README.md
	SHA1=$$(sha1sum build/usb-packages.manifest | cut -c1-8) && \
	sed "s/{SHA1}/$${SHA1}/g;s/{VERSION}/$${VERSION}/g;" < README.md > build/README-$(VERSION)-$${SHA1}.md && \
	make build/README.html && \
	cd .cache && \
	zip ../$@ $(FILES) usb-packages.manifest README-$(VERSION)-$${SHA1}.md && \
	cd .. && \
	cd build && \
	zip ../$@ usb-packages.manifest README-$(VERSION)-$${SHA1}.md && \
	cd .. && \
	cp $@ build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.zip && \
	sha1sum $@ | cut -f1 -d' ' > build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.zip.sha1

build/usb-packages.manifest: usb-packages.manifest.json
	jq -r '.packages[]|.sha1+" "+.file' usb-packages.manifest.json | sort -k 2 -t ' ' > build/usb-packages.manifest

publish: build/README.html
	SHA1=$$(sha1sum build/usb-packages.manifest | cut -c1-8) && \
	s3cmd sync -P build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.README.html s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.zip s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.zip.sha1 s3://firmware.sphere.ninja/latest/

build/README.html: README.md
	SHA1=$$(sha1sum build/usb-packages.manifest | cut -c1-8) && \
	markdown build/README-$(VERSION)-$${SHA1}.md  > build/ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$(VERSION)-$${SHA1}.README.html

clean:
	rm -rf build
	mkdir -p build

clean-cache:
	-rm -rf .cache

files:
	./build.sh download
