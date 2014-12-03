#!/bin/sh

die() {
	echo "$*" 1>&2
	exit 1
}

patch() {

	type=$1
	test $# -ge 1 && shift 1
	case "$type" in
	wpa)
		ssid=$1
		password=$2
	cat >/var/run/wpa_supplicant.conf <<EOF
ctrl_interface=/var/run/wpa_supplicant
update_config=1
EOF

if test -n "$password"; then
	cat >>/var/run/wpa_supplicant.conf <<EOF

network={
       ssid="$ssid"
       scan_ssid=1
       psk="$password"
       key_mgmt=WPA-PSK
}
EOF
fi
	ln -sf /var/run/wpa_supplicant.conf /etc
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
	nand)
mount -oremount,rw / &&
mkdir -p /opt/ninjablocks/factory-reset &&
(
		cd /var/volatile/run/media/mmcblk0p2/opt/ninjablocks/factory-reset;
		tar -cf - . ) |
(
		cd /opt/ninjablocks/factory-reset;
		tar -xf -) &&
		/opt/ninjablocks/factory-reset/bin/recovery.sh generate-env ubuntu_armhf_trusty_norelease_sphere-unstable http://odroid:8000/latest > /var/volatile/run/media/mmcblk0p4/recovery.env.sh &&
		if ! test -e /etc/wpa_supplicant.conf; then
			patch wpa
		fi
		if ! test -L /etc/wpa_supplicant.conf; then
			cp /etc/wpa_supplicant.conf /var/run &&
			ln -sf /var/run/wpa_supplicant.conf /etc/wpa_supplicant.conf
		fi &&
		mount -oremount,ro / &&
		echo ok || echo failed
	;;
	*)
		die "unsupported patch: $type"
	;;
	esac

}

main()
{
	cmd=$1
	case "$1" in
	init-io)
		if test -e /sys/kernel/debug/omap_mux/xdma_event_intr1; then
			# in later kernels (3.12) this path won't exist
			echo 37 > /sys/kernel/debug/omap_mux/xdma_event_intr1
		fi
		echo 20 > /sys/class/gpio/export
		echo in > /sys/class/gpio/gpio20/direction

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
		$(dirname "$0")/recovery.sh factory-reset "$@"
	;;
	patch)
		shift 1
		patch "$@"
	;;
	esac

}


main "$@"
