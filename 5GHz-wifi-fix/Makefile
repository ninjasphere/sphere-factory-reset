SCRIPTROCK=ninja-scriptrock_0.1~trustyspheramid-23_armhf.deb
WIRELESS_CONF=sphere-wireless-conf_0.2~trustyspheramid-5_armhf.deb

FILES=$(SCRIPTROCK) $(WIRELESS_CONF)

all: clean ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip

ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip: $(FILES) usb-packages.manifest README.md
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	sed "s/{SHA1}/$${SHA1}/g" < README.md > README-$${SHA1}.md && \
	zip $@ $(FILES) usb-packages.manifest README-$${SHA1}.md && \
	cp $@ ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.zip && \
	sha1sum $@ | cut -f1 -d' ' > ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.zip.sha1

usb-packages.manifest: $(FILES)
	sha1sum $(FILES) > usb-packages.manifest

publish: README.html
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.README.html s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.zip s3://firmware.sphere.ninja/latest/ && \
	s3cmd sync -P ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.zip.sha1 s3://firmware.sphere.ninja/latest/

README.html: README.md
	SHA1=$$(sha1sum usb-packages.manifest | cut -c1-8) && \
	markdown README-$${SHA1}.md  > ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages-$${SHA1}.README.html

clean:
	-rm ubuntu_armhf_trusty_norelease_sphere-stable-usb-packages.zip || true

clean-cache:
	-rm $(SCRIPTROCK) $(WIRELESS_CONF)

$(SCRIPTROCK):
	test -f $(SCRIPTROCK) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/n/ninja-scriptrock/$(SCRIPTROCK)

$(WIRELESS_CONF):
	test -f $(WIRELESS_CONF) || curl -O https://s3.amazonaws.com/ninjablocks-apt-repo/pool/main/s/sphere-wireless-conf/$(WIRELESS_CONF)
