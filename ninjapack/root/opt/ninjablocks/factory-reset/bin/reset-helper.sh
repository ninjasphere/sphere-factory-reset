#!/bin/sh

die() {
	echo "$*" 1>&2
	exit 1
}

factory_reset() {
	service spheramid stop
	service ledcontroller stop
	"$(dirname "$0")/recovery.sh" factory-reset "$@"
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
		shift 1
		# in this phase, we just exit with 0
		# the setup assistant binary will exit with 168 which will cause
		# it's wrapper script to start a factory reset
	;;
	factory-reset)
		shift 1
		factory_reset "$@"
	;;
	esac
}

main "$@"
