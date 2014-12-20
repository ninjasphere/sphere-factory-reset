RECOVERY_LIBRARY=true . $(dirname "$0")/../recovery.sh

FIXTURE_USB_SHA1_EXISTS=false
FIXTURE_USB_TAR_EXISTS=false

intercept_io() {
	case "$*" in
		sphere_io*)
			:
		;;
		test\ -f\ /var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar.sha1)
			${FIXTURE_USB_SHA1_EXISTS}
			return
		;;
		cp\ /var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar.sha1\ /var/volatile/run/media/mmcblk0p4)
			assertTrue "SHA1 exists" ${FIXTURE_USB_SHA1_EXISTS}
			return 0
		;;
		cp\ /var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar\ /var/volatile/run/media/mmcblk0p4)
			assertTrue "TAR exists" ${FIXTURE_USB_TAR_EXISTS}
			return 0
		;;
		*)
			die "ERR5xx: unexpected io during unit test: $*"
		;;
	esac
}

require() {
	case "$*" in
		mounted\ /dev/mmcblk0p4)
			echo "${RECOVERY_MEDIA}/mmcblk0p4"
		;;
		*)
			die "ERR5xx: unexpected io during unit test: require $*"
		;;
	esac

}

usb_file() {
	case "$*" in
		ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar)
			echo "/var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar"
		;;
		*)
			die "ERR5xx: unexpected io during unit test: usb_file $*"
		;;
	esac
}

check_file() {
	case "$*" in
		/var/volatile/run/media/mmcblk0p4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar)
			return 1
		;;
		*)
			die "ERR5xx: unexpected io during unit test: check_file $*"
		;;
	esac
}

testUpdateTarFromUSB() {
	FIXTURE_USB_SHA1_EXISTS=true
	FIXTURE_USB_TAR_EXISTS=true
	update_from_usb $(url file .tar)
	assertTrue "Success." $?
}

testUpdateTarFromUSBNoFile() {
	FIXTURE_USB_SHA1_EXISTS=false
	FIXTURE_USB_TAR_EXISTS=false
	update_from_usb $(url file .tar)
	assertFalse "Failed." $?
}


eval "$(unit_test_script)"

