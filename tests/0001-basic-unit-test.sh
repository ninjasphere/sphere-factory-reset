RECOVERY_LIBRARY=true . $(dirname "$0")/../recovery.sh

testBasic() {
	assertTrue 0
}

testOnNand() {
	case "$(uname)" in
	Linux)
		if test "$(mount_point "ubi0:rootfs")" = "/"; then
			assertTrue "on_nand"
		else
			assertFalse "on_nand"
		fi
	;;
	*)
		assertFalse "on_nand"
	;;
	esac
}

testOnSphere() {
	case "$(uname)" in
	Linux)
		assertTrue "on_sphere"
	;;
	*)
		assertFalse "on_sphere"
	;;
	esac
}

testOnSdcard() {
	case "$(uname)" in
	Linux)
		if test "$(mount_point "/dev/mmcblk0p2")" = "/"; then
			assertTrue "on_sdcard"
		else
			assertFalse "on_sdcard"
		fi
	;;
	*)
		assertFalse "on_nand"
	;;
	esac
}

eval "$(unit_test_script)"
