#export RECOVERY_SPHERE_IO_BAUD=115200;
export RECOVERY_IMAGE=ubuntu_armhf_trusty_norelease_sphere-stable
export RECOVERY_FACTORY_TEST_PASSWORD="{factory-test-password}"
if test "${RECOVERY_FACTORY_TEST_PASSWORD}" = "{factory-test-password}"; then
	die "ERR509" "factory.env.sh must be edited before use to configure a password that is shared with the factory."
fi

if test -z "${RECOVERY_GUARANTEE_NAND_BOOT_UNTIL_RESET}"; then
	# by doing this, we guarantee that if a successfully flashed sphere
	# is ever rebooted into NAND while the USB containing this file is on it is attached
	# that it will do a full factory reset again - a process that will remove the copy of this file
	#
	# if we didn't do this, then there is a chance we'd leave a copy of this file in the NAND
	# which may prevent a field factory reset from working properly
	dd if=/dev/zero of=/dev/mmcblk0p1;
	export RECOVERY_GUARANTEE_NAND_BOOT_UNTIL_RESET=true
fi

post_reset_hook() {
	USB_FILE=$(usb_file "factory.env.sh")

	if test -e "$USB_FILE"; then
		USB_DIR=$(dirname "$USB_FILE")
		root=$(require mounted /dev/mmcblk0p2) &&
		data=$(require mounted /dev/mmcblk0p3) &&
		mount -o bind $data $root/data &&
		find "${USB_DIR}/factory-reset-packages" -maxdepth 1 -type f -name '*.deb' | while read deb; do
			cp "$deb" $root/tmp
		done
		chroot $root bash -c '
dpkg --force-confnew -i /tmp/*.deb && rm /tmp/*.deb;
echo factory:${RECOVERY_FACTORY_TEST_PASSWORD} | chpasswd;
'
	fi
}
