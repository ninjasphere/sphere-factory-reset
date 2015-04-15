SCRIPTROCK=ninja-scriptrock_0.1~trustyspheramid-23_armhf.deb
WIRELESS_CONF=sphere-wireless-conf_0.2~trustyspheramid-5_armhf.deb
FACTORY_TEST=ninjasphere-factory-test_1.0.22~trustyspheramid-4_armhf.deb
FIX_APPLICATOR=ninja-fix-applicator_0.1.0~trustyspheramid-8_armhf.deb

FILES=$(SCRIPTROCK) $(WIRELESS_CONF) $(FIX_APPLICATOR)

all: clean ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip

ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip: $(FILES) usb-packages.manifest README.md
	VERSION=$$(cat VERSION) && \
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	sed "s/{SHA1}/$${SHA1}/g;s/{VERSION}/$${VERSION}/g;" < README.md > README-$$VERSION-$${SHA1}.md && \
	make README.html && \
	zip $@ $(FILES) usb-packages.manifest README-$$VERSION-$${SHA1}.md && \
	cp $@ ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.zip && \
	sha1sum $@ | cut -f1 -d' ' > ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.zip.sha1

usb-packages.manifest: $(FILES)
	sha1sum $(FILES) > usb-packages.manifest

publish: README.html
	VERSION=$$(cat VERSION) && \
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.README.html s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.zip s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.zip.sha1 s3://firmware.sphere.ninja/latest/

README.html: README.md
	VERSION=$$(cat VERSION) && \
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	markdown README-$$VERSION-$${SHA1}.md  > ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$$VERSION-$${SHA1}.README.html

clean:
	-rm usb-packages.manifest
	-rm ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip || true


clean-cache:
	-rm $(SCRIPTROCK) $(WIRELESS_CONF) $(FACTORY_TEST) $(FIX_APPLICATOR)

$(SCRIPTROCK):
	test -f $(SCRIPTROCK) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/n/ninja-scriptrock/$(SCRIPTROCK)

$(FACTORY_TEST):
	test -f $(FACTORY_TEST) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/n/ninjasphere-factory-test/$(FACTORY_TEST)

$(FIX_APPLICATOR):
	test -f $(FIX_APPLICATOR) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/n/ninja-fix-applicator/$(FIX_APPLICATOR)

$(WIRELESS_CONF):
	test -f $(WIRELESS_CONF) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/s/sphere-wireless-conf/$(WIRELESS_CONF)
