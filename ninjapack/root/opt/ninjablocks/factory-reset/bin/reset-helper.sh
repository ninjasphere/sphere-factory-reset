#!/bin/sh

die() {
	echo "$*" 1>&2
	exit 1
}

progress() {
	echo "$*" 1>&2
}

# setup the recovery environment. look for an environment far on the image partition and use it, if it exists.
setup() {
	RECOVERY_IMAGE_DEVICE=${RECOVERY_IMAGE_DEVICE:-/dev/mmcblk0p4}
	RECOVERY_SETUP_ASSISTANT=${RECOVERY_SETUP_ASSISTANT:-/opt/ninjablocks/factory-reset/bin/sphere-setup-assistant-iw29}

	if mountpoint=$(mount_helper require-mounted "${RECOVERY_IMAGE_DEVICE}" /tmp/image); then
		if test -f "$mountpoint/recovery.env.sh"; then
			echo "info: found '$mountpoint/recovery.env.sh' - loading..." 1>&2
			. "$mountpoint/recovery.env.sh"
		else
			echo "info: no overrides found in '$mountpoint/recovery.env.sh' - using defaults" 1>&2
		fi
	else
		echo "warning: could not find recovery image device - using defaults" 1>&2
	fi
}

patch() {

	type=$1
	test $# -ge 1 && shift 1
	case "$type" in
	wpa)
		ssid=$1
		password=$2
	cat >/etc/wpa_supplicant.conf <<EOF
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
       ssid="$ssid"
       scan_ssid=1
       psk="$password"
       key_mgmt=WPA-PSK
}
EOF
	;;
	opkg)
		if ! grep "src all http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/all" /etc/opkg/opkg.conf > /dev/null 2>&1; then
cat >> /etc/opkg/opkg.conf <<EOF
src all http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/all
src cortexa8hf-vfp-neon-3.8 http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/cortexa8hf-vfp-neon-3.8
src varsomam33 http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/varsomam33
EOF
		fi
	;;
	*)
		die "unsupported patch: $type"
	;;
	esac

}

#
# provides two functions to support mounting of a device
#
mount_helper() {

	cmd=$1
	device=$2
	mountpoint=$3
	case "$cmd" in
	mount-point)
		df | tr -s ' ' | cut -f1,6 -d' ' | grep "^$device" | cut -f2 -d' '
	;;
	require-mounted)
		test -n "$mountpoint" || die "usage: mount_helper require-mounted {device} {mountpoint}"
		current=$(mount_helper mount-point "$device")

		if test -z "$current"; then
			progress "mounting $device..."
			test -d "$mountpoint" || mkdir -p "$mountpoint" &&
			/bin/mount "$device" "$mountpoint" &&
			current=$(mount_helper mount-point "$device")
		fi

		if test -n "$current"; then
			echo "$current"
			progress "$device is mounted."
			return 0
		else
			progress "$device could not be mounted."
			die "ERR001: failed to mount $device"
		fi
	;;
	require-unmounted)
		current=$(mount_helper mount-point "$device")

		if test -n "$current"; then
			progress "unmounting $device..."
			/bin/umount "$device" &&
			current=$(mount_helper mount-point "$device")
		fi

		if test -z "$current"; then
			progress "$device is unmounted."
			return 0
		else
			progress "$device could not be dismounted."
			die "ERR002: failed to unmount $device"
		fi
	;;
	esac
}

#
# provide functions that answer parts of a URL
#
url() {
	id=$1
	case "$id" in
	prefix)
		echo ${RECOVERY_PREFIX:-https://firmware.sphere.ninja/latest}
	;;
	image)
		echo ${RECOVERY_IMAGE:-ubuntu_armhf_trusty_release_sphere-stable}
	;;
	suffix)
		echo ${RECOVERY_SUFFIX:--recovery}$2
	;;
	url)
		echo $(url prefix)/$(url image)$(url suffix "$2")
	;;
	esac
}

# OSX basename doesn't like -recovery in the basename unless -s is used, but Linux is ok with it
gnu_basename()
{
	case "$(uname)" in
	"Darwin")
		basename -s "$2" "$1"
	;;
	*)
		basename "$1" "$2"
	;;
	esac
}

# NAND image doesn't have sha1sum, but does have openssl sha1, which exists elsewhere too
sha1() {
	openssl sha1 | sed "s/.*= //"
}

# check that contents of a file has the same sha1sum as the contents of a co-located .sha1 file
check_file() {
	file=$1
	progress "verifying checksum of '$file'..."
	filesum="$(sha1 < "${file}")"
	checksum="$(cat "${file}.sha1")"
	test "$filesum" = "$checksum" || die "ERR003: checksum failed: '$file' $filesum != $checksum"
	progress "verified '$file' has checksum $checksum."
}

# download the recovery script and report the location of the downloaded file
download_recovery_script() {
	sha1name=/tmp/$(url image)$(url suffix .sh.sha1)
	shname=/tmp/$(url image)$(url suffix .sh)

	! test -f "$sha1name" || rm "$sha1name" || die "ERR004: could not delete existing sha1 file - $sha1name"
	! test -f "$shname" || rm "$shname" || die "ERR005: could not delete existing sh file - $shname"

	sha1url="$(url url .sh.sha1)"
	shurl="$(url url .sh)"

	progress "downloading ${sha1url}..." &&
	curl -s "${sha1url}" > "$sha1name" &&
	progress "downloaded." &&
	progress "downloading ${shurl}..." &&
	curl -s "${shurl}" > "$shname" &&
	progress "downloaded." &&
	check_file "$shname" &&
	echo $shname || die "ERR006: failed to download '$(url url .sh)' to '$shname'"
}

# checks that we are in at least 2014
check_time() {
	year=$(date +%Y)
	test "$year" -ge 2014 || die "ERR007: bad clock state: $(date "+%Y-%m-%d %H:%M:%S")"
}

# if the specified recovery image exists in the image mountpoint use it. if that image doesn't
# exist, look for a -recovery.tar and use that instead.
image_from_mount_point() {
	local mountpoint=$1
	if test -f "$mountpoint/${RECOVERY_IMAGE}/$(url suffix .tar)"; then
		echo "${RECOVERY_IMAGE}"
	else
		basename=$(gnu_basename "$(ls -d $mountpoint/*-recovery.tar | sort | tail -1)" "$(url suffix .tar)")
		if test -n "$basename"; then
			echo "$basename"
		else
			echo "${RECOVERY_IMAGE}"
		fi
	fi
}

interfaces() {
	case "$1" in
	up)
		if ! ifconfig | grep ^wlan0 >/dev/null; then
				ifup wlan0
		fi
		if ! hciconfig hci0 | tr \\011 ' ' | grep "^  *UP" >/dev/null; then
				hciconfig hci0 up
		fi
	;;
	*)
		die "'$1' is not a supported command"
	;;
	esac
}

# initiate the factory reset
factory_reset() {
	# check_time
	export RECOVERY_PREFIX
	export RECOVERY_IMAGE
	export RECOVERY_SUFFIX

	progress "factory reset starts..."

	attempt() {
		if recovery_script=$(download_recovery_script) && test -f "$recovery_script"; then
			progress "launching recovery script '$recovery_script'..."
			sh "$recovery_script" recovery-with-network
		else
			progress "failed to download recovery script."
			if ! mountpoint="$(mount_helper require-mounted "${RECOVERY_IMAGE_DEVICE}" /tmp/image)"; then
				die "ERR008: unable to mount recovery image device: ${RECOVERY_IMAGE_DEVICE}"
			else
				RECOVERY_IMAGE=$(image_from_mount_point "$mountpoint")
				script_file="$(url image)$(url suffix .sh)"
				sha1_file="$(url image)$(url suffix .sh.sha1)"
				tar="$mountpoint/$(url image)$(url suffix .tar)"
				unpacked_script="/tmp/${script_file}"
				unpacked_sha1="/tmp/${sha1_file}"
				if test -f "$tar"; then
					progress "unpacking ${script_file} from $tar..." &&
					tar -O -xf "$tar" "${script_file}" > "${unpacked_script}" &&
					progress "unpacking ${sha1_file} from $tar..." &&
					tar -O -xf "$tar" "${sha1_file}" > "${unpacked_sha1}" &&
					check_file "${unpacked_script}" &&
					progress "launching ${unpacked_script} from $tar..." &&
					sh "${unpacked_script}" recovery-without-network "$tar"
				else
					die "ERR009: could not locate recovery tar on recovery image device"
				fi
			fi
		fi
	}

	interfaces up

	while ! (attempt); do
		// try to configure the network
		sphere_installDirectory=/tmp ${RECOVERY_SETUP_ASSISTANT} --factory-reset
	done
}

main()
{
	setup
	cmd=$1
	case "$1" in
	init-io)
		if test -e /sys/kernel/debug/omap_mux/xdma_event_intr1; then
			# in later kernels (3.12) this path won't exist
			echo 37 > /sys/kernel/debug/omap_mux/xdma_event_intr1
			echo 20 > /sys/class/gpio/export
			echo in > /sys/class/gpio/gpio20/direction
		fi

		# to read the reset button
		# cat /sys/class/gpio/gpio20/value
	;;
	reboot)
		/sbin/reboot
	;;
	reset-userdata)
		# TBD: write scripts that will reset the user-data
		sphere-reset --reset-setup
		/sbin/reboot
	;;
	reset-root)
		# TBD: write scripts that will reset the root partition
		sphere-reset --reset-setup
		/sbin/reboot
	;;
	factory-reset)
		shift 1
		factory_reset "$@"
	;;
	download-recovery-script)
		shift 1
		download_recovery_script "$@"
	;;
	image-from-mount-point)
		shift 1
		image_from_mount_point "$@"
	;;
	url)
		shift 1
		url "$@"
	;;
	patch)
		shift 1
		patch "$@"
	;;
	esac

}


main "$@"
