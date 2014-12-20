RECOVERY_LIBRARY=true . $(dirname "$0")/../recovery.sh


require() {
	case "$*" in
	mounted*)
		set -- "$@"
		echo /var/volatile/run/media/$(basename $2)
	;;
	*)
		escape_subshell fail "unexpected mount invocation: $*"
	;;
	esac
}

find() {
	case "$*" in
	"/dev -maxdepth 1 -type b -name /dev/sda[0-9]*")
if ${FIXTURE_HAVE_USB}; then
		cat <<EOF
/dev/sda1
/dev/sda2
/dev/sda3
/dev/sda4
EOF
fi
	;;
	"/var/volatile/run/media/mmcblk0p4 -type f -maxdepth 1 -name ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar")
	;;
	/var/volatile/run/media/sda[1-3]\ -type\ f\ -maxdepth\ 1\ -name\ ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar)
	;;
	"/var/volatile/run/media/sda4 -type f -maxdepth 1 -name ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar")
	if ${FIXTURE_FOUND_ON_USB} && ${FIXTURE_HAVE_USB}; then
		echo /var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar
	fi
	;;
	*)
		escape_subshell fail "unexpected: find $*"
		return 1
	;;
	esac
}

check_file() {
	case "$*" in
	/var/volatile/run/media/sda4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar)
		assertTrue "${FIXTURE_FOUND_ON_USB}"
		return 0
	;;
	/var/volatile/run/media/mmcblk0p4/ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar)
		assertTrue "! ${FIXTURE_FOUND_ON_USB}"
	;;
	*)
		escape_subshell fail "unexpected: check_file $*"
	;;
	esac
}

testDiscoverTarFoundOnUSB() {
	FIXTURE_HAVE_USB=true
	FIXTURE_FOUND_ON_USB=true
	expose_subshell 'tar=$(discover_tar)'
	assertTrue $?
	assertTrue 'test -n "$tar"'
}

testDiscoverTarNotFoundOnUSB() {
	FIXTURE_HAVE_USB=true
	FIXTURE_FOUND_ON_USB=false
	expose_subshell 'tar=$(discover_tar)'
	assertFalse $?
	assertFalse 'test -n "$tar"'
}

testDiscoverTarNotFoundNoUSB() {
	FIXTURE_HAVE_USB=false
	FIXTURE_FOUND_ON_USB=false
	expose_subshell 'tar=$(discover_tar)'
	assertFalse $?
	assertFalse 'test -n "$tar"'
}

eval "$(unit_test_script)"

