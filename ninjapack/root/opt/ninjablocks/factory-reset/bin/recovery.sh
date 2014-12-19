#!/bin/sh

# ensure that all of the following are in the PATH somewhere
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

${RECOVERY_TRACE} # set this to set -x to see a trace of execution

export PARTITION_TABLE_SHA1SUM=6668e736cec8c065d6dfcdea3f9db5e2311bfaed
export RECOVERY_FACTORY_RESET=$(cd "$(dirname "$0")/.."; pwd)
export RECOVERY_SETUP_IMAGES=${RECOVERY_FACTORY_RESET}/images
export TMPDIR=${TMPDIR:-/tmp}
export RECOVERY_SDCARD=${RECOVERY_SDCARD:-mmcblk0}
export RECOVERY_REBOOT=${RECOVERY_REBOOT:-reboot}
export RECOVERY_ENABLE_SPHERE_IO=${RECOVERY_ENABLE_SPHERE_IO:-false}
export RECOVERY_ENABLE_SPHERE_IO_FACTORY_RESET=${RECOVERY_ENABLE_SPHERE_IO_FACTORY_RESET:-true}
export RECOVERY_MEDIA=${RECOVERY_MEDIA:-/var/volatile/run/media}
export RECOVERY_IMAGE_DEFAULT=${RECOVERY_IMAGE_DEFAULT:-ubuntu_armhf_trusty_norelease_sphere-stable}
export RECOVERY_IMAGE=${RECOVERY_IMAGE:-${RECOVERY_IMAGE_DEFAULT}}
export RECOVERY_PREFIX_DEFAULT=${RECOVERY_PREFIX_DEFAULT:-https://firmware.sphere.ninja/latest}
export RECOVERY_PREFIX=${RECOVERY_PREFIX:-${RECOVERY_PREFIX_DEFAULT}}
export RECOVERY_ENABLE_TMP_CLEANUP=${RECOVERY_ENABLE_TMP_CLEANUP:-false}
export RECOVERY_ENABLE_SCRIPT_PHASES=${RECOVERY_ENABLE_SCRIPT_PHASES:-true}
export RECOVERY_ENABLE_REBOOT_ON_REPARTITIONING=${RECOVERY_ENABLE_REBOOT_ON_REPARTITIONING:-true}
export RECOVERY_ARCHIVE_DELEGATION_RULE=${RECOVERY_ARCHIVE_DELEGATION_RULE:-more-recent}
export RECOVERY_CHROOT=${RECOVERY_CHROOT:-false}
export RECOVERY_SPHERE_IO_BAUD=${RECOVERY_SPHERE_IO_BAUD:-230400}

die() {
	msg="$*"
	if test "${msg#ERR[345]}" = "$msg"; then
		msg="ERR500: $msg"
	fi
	echo "$msg" 1>&2
	code=$(echo "$msg" | sed -n "s/^ERR\([0-9]*\):.*/\1/p")
	if test -n "$code"; then
		sphere_io --baud ${RECOVERY_SPHERE_IO_BAUD} --timeout-color=red --timeout=1 --disable-gestic=true --test="$code" --disable-mouse=true
	fi
	exit 1
}

sphere_io() {
	if ${RECOVERY_ENABLE_SPHERE_IO:-false}; then
		(
			# override to prevent recursion issues if tool_path dies
			die() {
				echo "$*" 1>&2
				exit 1
			}

			if ! sphere_io_path=$(tool_path "sphere-io"); then
				# don't die here because it'll be recursive
				return 1
			else
				$sphere_io_path "$@" 2>/dev/null
			fi
		) || return $?
	fi
}

trace_io() {
	"$@"
	trace_io_rc=$?
	echo "IO: $* -> $trace_io_rc" 1>&2
	return $trace_io_rc
}

# this function serves to redirect io, useful in creating mock test cases, etc
io() {
	${RECOVERY_IO_REDIRECT} "$@"
}

progress() {
	code=$1
	test -n "$code" || die "ERR415: usage progress {status-code} {message}"
	shift 1
	echo "STATUS$code: $*" 1>&2
	code=$(echo "$code" | sed -n "s/^\([0-9]*\).*/\1/p")
	if test -n "$code"; then
		io sphere_io --baud ${RECOVERY_SPHERE_IO_BAUD} --timeout-color=blue --timeout=1 --disable-gestic=true --test="$code" || true
	fi
}

messages() {
	(
		grep ERR[345] "$0" | sed "s/.*die \"\(.*\)\"\$/\1/" | grep ^ERR
		grep 'progress \"' "$0" | tr \\011 ' '| sed -n 's/.* progress \"\([^"]*\)" \"\(.*\)\".*/STATUS\1: \2/p'
	) | sort
}

usage() {
	if test -f "$(dirname "$0")/recovery.md"; then
		cat "$(dirname "$0")/recovery.md"
	elif test -f "$(dirname "$0")/../doc/recovery.md"; then
		cat "$(dirname "$0")/../doc/recovery.md"
	else
		io curl -s "https://raw.githubusercontent.com/ninjablocks/linux-rootfs-scripts/master/recovery.md?token=AAMpGwA2eW6cHZsezefem5jy8PuEtQKDks5Ui5-FwA%3D%3D"
	fi | ${PAGER:-less}
	exit 1
}

# setup the recovery environment. look for an environment far on the image partition and use it, if it exists.
setup() {
	if mountpoint=$(require mounted "$(sdcard)p4" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
		if test -f "$mountpoint/recovery.env.sh"; then
			progress "0030" "Loading environment from '$mountpoint/recovery.env.sh'..."
			. "$mountpoint/recovery.env.sh"
		else
			progress "0031" "No environment overrides found in '$mountpoint/recovery.env.sh'..."
		fi
	else
		progress "0032" "Could not mount image device."
	fi

	if ${RECOVERY_ENABLE_SPHERE_IO:-false}; then
		if test -x "${RECOVERY_FACTORY_TEST}/bin/reset-led-matrix"; then
			"${RECOVERY_FACTORY_TEST}/bin/reset-led-matrix" 2>/dev/null
		fi
	fi
}

# NAND image doesn't have sha1sum, but does have openssl sha1, which exists elsewhere too
sha1() {
	openssl sha1 | sed "s/.*= //"
}

bytes() {
	echo 3221225472
}

heads() {
	echo 255
}

sectors() {
	echo 63
}

sector_size() {
	echo 512
}

cylinders() {
	expr $(bytes) / $(sectors) / $(heads) / $(sector_size)
}

boot_mb() {
	expr $(boot_cylinders) \* $(sectors) \* $(heads) \* $(sector_size) / 1024 / 1024
}

boot_cylinders() {
	echo 9
}

blank_image() {
	image=$1
	truncate -s "$(bytes)" "$image"
	write_partition_table "$image"
}

sdcard() {
	if ${RECOVERY_BUILD:-false} || test "$(hostname)" = "odroid"; then
		# We should never be doing anyfhing with an actual sdcard
		# on the build machine. If we are trying to, then redirect
		# the operation to a device that hsould barf.
		echo /dev/no-such-device
	else
		echo /dev/${RECOVERY_SDCARD}
	fi
}

partition_table() {
	cat <<EOF
,$(boot_cylinders),0x0C,*
,167,,-
,150,,-
,65,,-
EOF
}

on_nand() {
	if test "$(mount_point ubi0:rootfs)" = "/"; then
		echo true;
	else
		echo false;
		return 1
	fi
}

generate_env() {
	image="${1:-${RECOVERY_IMAGE_DEFAULT}}"
	prefix="${2:-${RECOVERY_PREFIX_DEFAULT}}"
cat <<EOF
export RECOVERY_IMAGE=${image};
export RECOVERY_PREFIX=${prefix};
EOF
}

write_partition_table() {
	drive=$1
	if test -b "$drive" && ! $(on_nand); then
		# guard against accidentally running this on a build machine!
		die "ERR515: Illegal attempt to write partition table to block device when NAND is not mounted."
	fi

	progress "0040" "Writing partition table..."
	rc=1
	if partition_table | sfdisk --force -D -H $(heads) -S $(sectors) -C "$(cylinders)" "$drive"; then
		rc=0
		progress "0043" "Partition table write was successful."
	else
		rc=$?
		progress "0042" "Partition table update failed - $?."
	fi

	if $(on_nand); then
		progress "0044" "Probing '$drive' partition table..."
		if io partprobe "$drive"; then
			progress "0047" "Partition table probe of  '$drive' completed successfully."
		else
			rc=$?
			if test "${RECOVERY_ENABLE_REBOOT_ON_REPARTITIONING}" = "true"; then
				progress "0046" "Partition table probe of  '$drive' has failed - a reboot will happen in 30 seconds unless cancelled required $rc."
				sleep 30
				progress "0047" "Rebooting..."
				${RECOVERY_REBOOT:-false}
				sleep 60
			fi
			die "ERR516: A reboot was required to complete repartitioning but reboots are disabled. Use 'recovery.sh set enable-reboot-on-repartitioning true;'"
		fi
	fi

	return $rc

}


format_partitions() {
	block_device=$1
	shift 1

	test -n "${block_device}" || die "ERR405: usage: format-partitions {confrmation-code} {block-device} p{partition#}"

	while test $# -gt 0; do
		partition=$1
		shift 1
		require unmounted ${block_device}${partition}
		progress "0010" "Formatting partition ${block_device}${partition}..."

		partition_device="${block_device}${partition}"
		if ! test -b "${partition_device}"; then
			die "ERR406: The specified partition device '${partition_device}' does not exist."
		fi

		case "$partition" in
		p1)
			mkfs.vfat -F 32 -n "boot" "${partition_device}" || die "ERR521: Failed to format '${partition_device}'."
		;;
		p2)
			mke2fs -j -L "Ninja" "${partition_device}" || die "ERR522: Failed to format '${partition_device}'."
		;;
		p3)
			mkfs.f2fs -l "UserData" "${partition_device}" || die "ERR523: Failed to format '${partition_device}'."
		;;
		p4)
			mkfs.f2fs -l "Image" "${partition_device}" || die "ERR524: Failed to format '${partition_device}'."
		;;
		esac
		progress "0019" "Formatting of '${block_device}${partition}' is complete."
	done
}

check_partition_table() {
	check="$(partition_sha1sum "$1")"
	if test "$check" = "$PARTITION_TABLE_SHA1SUM"; then
		echo true
	else
		echo false
		die "ERR331: Partition table checksum mismatch. Expected '${PARTITION_TABLE_SHA1SUM}' found '$check'."
	fi
}

partition_sha1sum() {
	block_device=$1
	test -n "$block_device" || die "ERR410: usage: partition-sha1sum {block-device-or-image}"
	test -e "$block_device" || die "ERR411: The partition specified by '$block_device' does not exist."
	sfdisk -d "$block_device" | sed -n "s/.* : start=//p" | sha1
}

confirmation_code()
{
	echo "$*" | sha1
}

confirmed_action() {
	method=$1
	test $# -ge 2 || die "ERR420: usage: confirmed_action {method} {confirmation-code} args..."
	confirmation=$2
	shift 2
	specified=$(confirmation_code "$@")
	test "$confirmation" = "$specified" || die "ERR421: The specified confirmation code '$confirmation' does not match the specified arguments '$*'."
	$method "$@"
}

wpa_supplicant() {
	case "$1" in
	physical)
		if $(on_nand); then
			echo /var/run/wpa_supplicant.conf
		else
			echo /data/etc/wpa_supplicant.conf
		fi
	;;
	*)
		die "ERR430: usage: wpa_supplicant physical"
	;;
	esac

}

curl_continue() {
	#deprecate support for byte ranges because they are not supported by S3.
	curl "$@"
}

untar() {
	tar=$1
	file=$2
	block_device=$3
	partition=$4

	progress "0600" "Reimaging '$block_device$partition'..."
	format_partitions "$block_device" "$partition"
	mountpoint=$(require mounted $block_device$partition ${RECOVERY_MEDIA}/$(basename $block_device$partition)) || exit $?
	progress "0602" "Extraction of tar '$tar' begins..."
	if tar -O -xf "$tar" "$file" | gzip -dc | (cd $mountpoint; tar -xf -); then
		progress "0607" "Extraction of tar '$tar' begins..."
	else
		progress "0606" "Extraction of tar '$tar' failed."
	 	die "ERR532: Failed to extract '$tar' to '$block_device$partition'."
	fi
	sync
	mountpoint=$(require unmounted "$block_device$partition") || exit $?
	progress "0699" "Reimaging of '$block_device$partition' has completed successfully."
}

# recover without network using the specified tar
recovery_without_network() {


	tar="$1"
	test -n "$tar" || die "ERR441: usage: recovery-without-network {tar}."
	test -f "$tar" || die "ERR442: The specified recovery tar '$tar' does not exist."


	if $(on_nand); then

		progress "9000" "Recovery without network commences."

		(check_file "$tar") || progress "9001" "Ignoring checksum failure..."

		progress "9100" "Reimaging of data partition begins..."
		untar "$tar" data.tgz $(sdcard) p3
		progress "9199" "Reimaging of data partition is complete"

		progress "9200" "Reimaging of root partition begins..."
		untar "$tar" root.tgz $(sdcard) p2
		progress "9250" "Reimaging of root is complete."

		progress "9251" "Removing factory flash settings..."
		block() {
			if test -f /etc/factory.env.sh; then
				rm /etc/factory.env.sh;
			fi
		}
		( with_rw block ) ; rc=$?
		progress "9252" "Removing factory flash settings has completed - $rc."

		progress "9300" "Reimaging of boot partition begins..."
		untar "$tar" boot.tgz $(sdcard) p1
		progress "9399" "Reimaging of boot partition ends."

		if rootdir=$(require mounted $(sdcard)p2 ${RECOVERY_MEDIA}p2); then
			 date -u +%Y%m%dT%H%M%S > $rootdir/etc/.recovered
		fi
		sync

		progress "9997" "Reimaging is complete."
	else
		progress "8500" "Forcing boot to NAND in recovery mode..."
		require unmounted $(sdcard)p1

		progress "8501" "Backing up boot partition"
		if imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
			io dd if="$(sdcard)p1" of="${imagedir}/boot.img" bs=1M
			size=$(cat "${imagedir}/boot.img" | wc -c)
			! test -f "${imagedir}/boot.img.gz" || rm "${imagedir}/boot.img.gz"
			gzip "${imagedir}/boot.img"
			size=$(expr $size / 1024 / 1024)
		else
			size=$(boot_mb)
		fi

		progress "8503" "Blanking boot partition with '${size}' MB of zero."
		io dd if=/dev/zero of=$(sdcard)p1 count=${size}M bs=$(expr 1024 \* 1024)
		if test "${RECOVERY_BOOT}" = "reboot"; then
			progress "8599" "Rebooting into NAND..."
		else
			progress "8598" "The boot partition has been nuked! Good luck and see you on the other side!"
		fi
		${RECOVERY_REBOOT}
	fi
}

# download the recovery script and report the location of the downloaded file
download() {
	case "$1" in
	recovery-script)
		progress "2500" "Downloading recovery script begins..."
		sha1name=${TMPDIR}/$(url image)$(url suffix .sh.sha1)
		shname=${TMPDIR}/$(url image)$(url suffix .sh)

		! test -f "$sha1name" || rm "$sha1name" || die "ERR535: Unable to delete existing file: '$sha1name'."
		! test -f "$shname" || rm "$shname" || die "ERR536: Unable to delete existing file: '$shname'."

		sha1url="$(url url .sh.sha1)"
		shurl="$(url url .sh)"

		if
			progress "2501" "Downloading ${sha1url}..." &&
			(cd ${TMPDIR} && retry 3 io curl_continue -O -s "${sha1url}") &&
			progress "2599" "Downloading of '${sha1url}' to '${sha1name}' is complete." &&
			progress "2600" "Downloading ${shurl}..." &&
			(cd ${TMPDIR} && retry 3 io curl_continue -O -s "${shurl}") &&
			progress "2697" "Downloading of '${shurl}' to '${shname}' is complete." &&
			check_file "$shname"; then
			progress "2699" "Downloading of recovery script is complete."
			echo $shname
		else
			progress "2698" "Downloading of recovery script has failed."
			die "ERR330: The download of the recovery script from '$(url url .sh)' to '$shname' has failed."
		fi
	;;
	git-recovery-script)
		io curl -s "${RECOVERY_GITHUB:-https://raw.githubusercontent.com}/ninjablocks/linux-rootfs-scripts/master/recovery.sh?token=AAMpG0k1MXOhoFcVbhs4Bog7aEzG6tOSks5UjCiuwA%3D%3D" > ${TMPDIR}/recovery.sh &&
		echo ${TMPDIR}/recovery.sh ||
		die "ERR555: failed to download recovery script from git."
	;;
	*)
		die "ERR443: usage: download recovery-script"
	;;
	esac
}

retry() {
	count=$1
	max=$count
	shift 1
	while ! "$@"; do
		count=$(expr $count - 1)
		if test $count -le 0; then
			die "ERR568: Failed after $max retries."
		fi
	done
	return 0
}

#
# provide functions that answer parts of a URL
#
url() {
	id=$1
	case "$id" in
	prefix)
		echo ${RECOVERY_PREFIX:-${RECOVERY_PREFIX_DEFAULT}}
	;;
	image)
		echo ${RECOVERY_IMAGE:-ubuntu_armhf_trusty_norelease_sphere-stable}
	;;
	suffix)
		echo ${RECOVERY_SUFFIX:--recovery}$2
	;;
	url)
		echo $(url prefix)/$(url image)$(url suffix "$2")
	;;
	esac
}

# check that a file exists and has the required checksum
check_file() {
	file=$1
	test -n "$file" || die "ERR460: usage: check_file {filename}"
	test -f "$file" || die "ERR301: The specified file '$file' does not exist."
	filesum="$(sha1 < "${file}")"
	progress "0100" "Verifying checksum of '$file'..."
	checksum="$(cat "${file}.sha1")"
	progress "0199" "Verification of checksum '$file' is complete."
	test "$filesum" = "$checksum" || die "ERR302: The specified '$file' does not have the specified checksum ('$checksum'). Actual checksum: ('$filesum')."
}

# this function recovers the boot partition from the recovery tar
recover_boot() {
	progress "9800" "Manual recovery of boot partition begins..."
	imagemount=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4) || exit $?
	image=$(image_from_mount_point "${imagemount}")
	tar="${imagemount}/${image}$(url suffix .tar)"
	check_file "$tar"
	format_partitions $(sdcard) p1
	if !(untar "$tar" boot.tgz $(sdcard) p1); then
		if test -f "${imagemount}/boot.img.gz"; then
			if $(require unmounted $(sdcpard)p1); then
				gzip -dc "${imagemount}/boot.img.gz" | dd of=$(sdcard)p1 bs=1M
			else
				die "ERR511: Unable to unmount boot partition."
			fi
		else
			die "ERR512: Could not find backup of boot partition."
		fi
	fi
	progress "9899" "Manual recovery of boot partition is complete."
}

# this function recovers the boot partition from the recovery tar
recover_data() {
	progress "9700" "Manual recovery of data partition begins..."
	imagemount=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4) || exit $?
	image=$(image_from_mount_point "${imagemount}")
	tar="${imagemount}/${image}$(url suffix .tar)"
	check_file "$tar"
	format_partitions $(sdcard) p3
	untar "$tar" data.tgz $(sdcard) p3
	progress "9799" "Manual recovery of data partition is complete."
}

force_partitioning() {

	progress "8010" "Stopping udev"
	if test -x /etc/init.d/udev; then
		/etc/init.d/udev stop
		sleep 5
	fi

	# enumerate all mounted devices and unmount them all
	df | tr -s ' ' | cut -f1,6 -d' ' | grep "^$(sdcard)" | while read dev mp; do
		echo ${#mp} $mp
	done | sort -nr | while read n mp; do
		progress "8013" "Unmounting '${mp}'..."
		if io umount "${mp}"; then
			progress "8015" "Unmounting of '${mp}' has succeeded."
		else
			progress "8014" "Unmounting of '${mp}' has failed - $?."
		fi
	done

	progress "8017" "Rewriting partition table..."

	write_partition_table $(sdcard)
	progress "8018" "Checking partition table..."
	( check_partition_table $(sdcard) 1>/dev/null ) || die "ERR561: Failed to update partition table on '$(sdcard)'."

	progress "8021" "Trying to remount image partition..."
	if imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
		progress "8023" "Remounting of image partition was successful."
	else
		progress "8022" "Remounting of image partition failed. Trying to reformat it..."
		format_partitions $(sdcard) p4
	fi

	mkdir -p "${TMPDIR}" # ensure this directory exists, just in case we trashed it.

}

# if we have a network, then optionally repartition the disk
recovery_with_network() {

	progress "8000" "Recovery assuming network exists begins..."
	check deps
	progress "8001" "Checking partition table..."
	if ! (check_partition_table $(sdcard) 1>/dev/null); then
		progress "8002" "Differences found."
		if $(on_nand); then
			force_partitioning
		else
			progress "8028" "Partitioning required, but deferred until nand boot."
		fi
	fi

	if ! imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
		format_partitions $(sdcard) p4
	fi

	imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4) || exit $?
	imagetar="$imagedir/$(url image)$(url suffix .tar)"
	imagesha1="${TMPDIR}/$(url image)$(url suffix .tar.sha1)"
	imagesha1url=$(url url .tar.sha1)
	imageurl=$(url url .tar)
	progress "8030" "Downloading '${imagesha1url}' to '${imagesha1}'..."
	if (cd "${TMPDIR}" && retry 3 io curl_continue -O -s "$imagesha1url"); then
		cp  "$imagesha1" "$imagedir" || die "ERR563: Failed to copy '$imagesha1' to '$imagedir'."
		progress "8031" "Checking '${imagetar}'..."
		if ! ( check_file "$imagetar" ); then
			progress "8032" "Validation of '${imagetar}' failed."
			! test -f "$imagetar" || rm -f "$imagetar"
		fi

		progress "8033" "Downloading '${imageurl}' to '${imagetar}'..."
		if ! (cd "${imagedir}" && retry 3 io curl_continue -O -s "$imageurl"); then
			progress "8034" "Download from '${imageurl}' to '${imagetar}' failed."
			rm "$imagetar"
			die "ERR310: Failed to download '${imageurl}' to '${imagetar}'."
		else
			if ! ( check_file "$imagetar" ); then
				progress "8035" "Validation of '${imagetar}' failed."
			fi
			progress "8039" "Download of '${imageurl}' to '${imagetar}' is complete."
		fi
	else
		progress "8038" "Download from '${imagesha1url}' to '${imagesha1}' failed."
	fi


	if test -f "$imagetar"; then
		script_to_run=$0
		progress "8100" "Found recovery archive '$imagetar'. Extracting recovery script..."
		if tar -C ${TMPDIR} -xf "$imagetar" $(url image)$(url suffix .sh); then
			if test -x "${TMPDIR}/$(url image)$(url suffix .sh)"; then
				progress "8105" "Extracted executeble recovery script."
				if unpacked=$(with large-tmp sh ${TMPDIR}/$(url image)$(url suffix .sh) unpack); then
					progress "8107" "Unpacked recovery script to '$unpacked'."
					script_to_run="$unpacked/bin/recovery.sh"
				else
					progress "8106" "Unpacking failed."
				fi
			else
				progress "8104" "Could not find executeble recovery script in recovery tar."
			fi
		else
			progress "8102" "Failed to extract recovery script from recovery tar."
		fi

		progress "8999" "Recovery assuming network exists ends."

		exec sh $(choose_script "$script_to_run") recovery-without-network "$imagetar"
	else
		progress "8998" "Recovery assuming network exists ends badly."
		die "ERR564: The required recovery archive does not exist: '$imagetar'."
	fi
}

resolve_delegation() {
	delegator=$1
	delegatee=$2
	rule=${3:-${RECOVERY_ARCHIVE_DELEGATION_RULE}}

	test -n "$rule" &&
	test -n "$delegator" ||
	die "usage: resolve_delegation {rule} {delegator} [{delegatee}]"

	if test -z "$delegatee"; then
		if test -n "$delegator"; then
			echo "$delegator"
			return 0
		fi
	else
		if test -z "$delegator"; then
			echo "$delegatee"
			return 0
		fi
	fi

	unsorted=$(
cat <<EOF
$delegator
$delegatee
EOF
)

	sorted=$(
sort <<EOF
$delegator
$delegatee
EOF
)

	case "$rule" in
	always)
		test -n "$delegatee" && echo "$delegatee"
	;;
	never)
		test -n "$delegator" && echo "$delegator"
	;;
	more-recent)
		if test "$sorted" = "$unsorted"; then
			echo "$delegatee"
		else
			echo "$delegator"
		fi
	;;
	*)
		die "rule '$rule' is not supported"
	esac
}


check() {
	case "$1" in
	deps)
		progress "0200" "Checking required dependencies..."
		test -x "$(which sfdisk)" || die "ERR571: The required command 'sfdisk' is available in PATH."
		progress "0299" "Checking complete."
	;;
	*)
		die "ERR461: usage: check deps"
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

gnu_readlink()
{
	case "$(uname)" in
	Linux)
		readlink "$@"
	;;
	Darwin)
		greadlink "$@" || die "greadlink failed - use brew install coreutils to fix."
	;;
	esac
}

# if the specified recovery image exists in the image mountpoint use it. if that image doesn't
# exist, look for a -recovery.tar and use that instead.
image_from_mount_point() {
	mountpoint=$1
	if test -f "$mountpoint/$(url image)/$(url suffix .tar)"; then
		echo "$(url image)"
	else
		basename=$(gnu_basename "$(ls -d $mountpoint/*-recovery.tar | sort | tail -1)" "$(url suffix .tar)")
		if test -n "$basename"; then
			echo "$basename"
		else
			echo "$(url image)"
		fi
	fi
}

interfaces() {
	case "$1" in
	cycle)
		if $(on_nand) && ! test -e "$(wpa_supplicant physical)"; then
			progress "3050" "Patching wpa_supplicant.conf..."
			if (patch wpa); then
				progress "3059" "Patching wpa is complete..."
			else
				progress "3058" "Patching wpa has failed."
			fi
		else
			progress "3051" "The wpa_supplicant.conf file exists."
		fi

		progress "3100" "Taking wlan0 down..."
		if io ifconfig wlan0 down; then
			progress "3103" "Taking wlan0 down is complete."
		else
			progress "3102" "Taking wlan0 down has failed."
		fi

		progress "3110" "Bringing wlan0 up (ifconfig)..."
		if io ifconfig wlan0 up; then
			progress "3113" "Bringing wlan0 up (ifconfig) is complete."
		else
			progress "3112" "Bringing wlan0 up (ifconfig) has failed."
		fi

		progress "3230" "Reconfiguring wpa..."
		if io wpa_cli reconfigure; then
			progress "3233" "wpa reconfiguration is complete."
		else
			progress "3232" "wpa reconfiguration has failed."
		fi

		if $(on_nand); then
			progress "3320" "Bring wlan0 up (ifup)..."
			if (retry 3 sh -c 'ifdown wlan0 && ifup wlan0'); then
				progress "3313" "Bringing up wlan0 up (ifup) is complete."
			else
				progress "3312" "Bringing up wlan0 up (ifup) has failed."
			fi
		fi

		progress "3301" "Taking hci0 down..."
		if io hciconfig hci0 down; then
			progress "3399" "Taking hci0 down is complete."
		else
			progress "3398" "Taking hci0 down has failed."
		fi

		progress "3401" "Bringing hci0 up..."
		if io hciconfig hci0 up; then
			progress "3499" "Bringing hci0 up is complete."
		else
			progress "3498" "Bringing hci0 up failed."
		fi

	;;
	*)
		die "ERR465: usage: interfaces cycle"
	;;
	esac
}

tool_path() {
	tool=$1
	bin=
	test -n "$tool" || die "ERR466: usage tool-path {tool}"
	if test -x "${RECOVERY_FACTORY_RESET}/bin/${tool}"; then
		bin="${RECOVERY_FACTORY_RESET}/bin/${tool}"
	else
		if ! bin=$(which "${tool}"); then
			die "ERR567: Unable to locate tool: '${tool}'"
		fi
	fi
	echo $bin

}

setup_assistant_path() {
	bin=
	if $(on_nand); then
		bin=$(tool_path sphere-setup-assistant-iw29)
	else
		bin=$(tool_path sphere-setup-assistant.bin)
	fi
	test -n "$bin" || exit $?
	echo "$bin"
}

factory_setup_assistant() {
	progress "3500" "Launching setup assistant to acquire network credentials..."

	progress "3501" "Cycling interfaces before launching setup assistant..."
	interfaces cycle

	setup_assistant_path=$(setup_assistant_path) || exit $?

	if PATH=${RECOVERY_FACTORY_RESET}/bin:$PATH sphere_installDirectory=/tmp "$setup_assistant_path" --factory-reset --images "${RECOVERY_SETUP_IMAGES}" "$@"; then
		progress "3503" "Factory setup assistant has exited successfully."
	else
		progress "3502" "Factory setup assistant has failed -$?."
	fi

	progress 3510 "Reconfiguring wpa..."
	if io wpa_cli reconfigure; then
		progress "3513" "WPA configuration was successful."
	else
		progress "3512" "WPA configuration was not successful - $?."
	fi

	progress 3521 "Bringing up ifup wlan0"
	if io ifup wlan0; then
		progress "3523" "The command 'ifup wlan0' was successful."
	else
		progress "3512" "The command 'ifup wlan0' was not successful - $?."
	fi

	# progress "3504" "Cycliing interfaces"
	# interfaces cycle

	progress "3597" "Waiting for wlan0 to settle..."
	sleep 10
	progress "3599" "Resuming recovery..."
}

# checks that we are in at least 2014
check_time() {
	year=$(date +%Y)
	test "$year" -ge 2014 || die "ERR320: The clock has a date in the past: $(date "+%Y-%m-%d %H:%M:%S")."
}

# answer the timestamp of the current script or 19991231T000000 if the script does not have one.
recovery_sh_timestamp() {
	file_ts=$(test -f "${RECOVERY_FACTORY_RESET}/etc/timestamp" && cat "${RECOVERY_FACTORY_RESET}/etc/timestamp")
	if test -z "$file_ts"; then
		# a script without a timestamp, is probably borked.
		echo "19991231T000000"
	else
		echo "${file_ts}"
	fi
}


choose_script() {

	script=$1
	if ${RECOVERY_ENABLE_SCRIPT_PHASES}; then
		selected=$0 && #failsafe
		self=$(recovery_sh_timestamp) && # our own timestamp
		other=$(
			other_home=$(cd $(dirname "$script")/..; pwd) &&
			test -f "${other_home}/etc/timestamp" &&
			other_timestamp=$(cat "${other_home}/etc/timestamp") &&
			echo "$other_timestamp"
		) &&		 # the potential delegate's times
		resolution=$(resolve_delegation "$self" "$other" "${RECOVERY_ARCHIVE_DELEGATION_RULE}") && # the resolved timestamp
		if test "$resolution" = "$self"; then
			progress "3603" "Found other script ('$other') but continuing with ('$self') because of rule ('${RECOVERY_ARCHIVE_DELEGATION_RULE}')"
			selected="$0"
		else
			progress "3609" "Delegating to alternative script '$script'."
			selected="$script"
		fi &&
		echo "$selected"
	else
		progress "3602" "Script phases are disabled by RECOVERY_ENABLE_SCRIPT_PHASES. Using '$0' instead of '$script'."
		# When debugging it can be confusing if the script keeps changing.
		echo "$0"
	fi
}

# initiate the factory reset
factory_reset() {

	mode=${1:-conditional}

	# check_time
	export RECOVERY_PREFIX
	export RECOVERY_IMAGE
	export RECOVERY_SUFFIX

	progress "1000" "Factory reset starts..."

	if test "$mode" != "force"; then
		progress "1001" "Checking boot partition..."
		if
			bootdir=$(require mounted "$(sdcard)p1" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p1) &&
			rootdir=$(require mounted "$(sdcard)p2" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p2) &&
			test -f $rootdir/etc/.recovered
		then
			progress "1002" "The boot partition is ok. Checking for user reset indication..."
			if sphere_io --baud ${RECOVERY_SPHERE_IO_BAUD} --test="zap" --color=red --ok=TapCenter --timeout=5; then
				progress "1003" "The user has requested a reset."
			else
				progress "1999" "The user has not requested a reset. Aborting reset."
				exit 0
			fi
		fi
	fi

	attempt() {
		if downloaded=$(download recovery-script) && test -f "$downloaded"; then
			progress 1010 "Launching recovery script '$downloaded'..."
			chmod ugo+x "$downloaded" &&
			unpacked=$(with large-tmp $downloaded unpack) &&
			recovery_script="$unpacked/bin/recovery.sh" &&
			test -f "$recovery_script" &&
			exec sh $(choose_script "$recovery_script") recovery-with-network
		else
			progress 1011 "Failed to download recovery script."
			mountpoint="$(require mounted "$(sdcard)p4" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4)" || exit $?
			RECOVERY_IMAGE=$(image_from_mount_point "$mountpoint")
			script_file="$(url image)$(url suffix .sh)"
			sha1_file="$(url image)$(url suffix .sh.sha1)"
			tar="$mountpoint/$(url image)$(url suffix .tar)"
			unpacked_script="${TMPDIR}/${script_file}"
			unpacked_sha1="${TMPDIR}/${sha1_file}"

			if test -f "$tar"; then
				progress "1012" "Unpacking ${script_file} from $tar..." &&
				tar -O -xf "$tar" "${script_file}" > "${unpacked_script}" &&
				progress "1015" "Unpacking ${sha1_file} from $tar..." &&
				tar -O -xf "$tar" "${sha1_file}" > "${unpacked_sha1}" &&
				check_file "${unpacked_script}" &&
				progress 1019 "Launching ${unpacked_script} from $tar..." &&
				exec sh $(choose_script "${unpacked_script}") recovery-without-network "$tar"
			else
				progress 1014 "Failed to locate a recovery archive"
				if test -f "$tar"; then
					progress "1016" "Removing corrupted tar '$tar'."
					if ! rm "$tar"; then
						progress "1018" "Failed to remove corrupted '$tar'."
					fi
				fi
				die "ERR341: The required recovery archive '$tar' does not exist or was corrupt."
			fi
		fi
	}

	(patch eth2)

	progress "2000" "First recovery attempt..."
	count=1
	while ! (attempt); do
		progress "2997" "Recovery attempt failed."

		if test -z "$(ifconfig eth2 | grep inet | sed "s/.*inet addr://;s/ .*//")"; then
			factory_setup_assistant
		else
			progress "2998" "Skipping setup assistant because 'eth2' device exists."
			sleep 2
		fi
		count=$(expr $count + 1)
		progress "2001" "Retrying recovery attempt ($count)..."
	done

	sync
	sleep 5
	sync
	progress "9998" "Recovery steps complete."
	${RECOVERY_REBOOT}
	progress "9999" "Recovery command ends."
}

# Answer the mount point associated with the specified device or empty string otherwise
# Set zero status if output is not empty.
mount_point()
{
	device=$1
	test -n "$device" || die "ERR470: usage mount-point {device}"
	_mp=$(
		df |
		tr -s ' ' |
		cut -f1,6 -d' ' |
		grep "^${device} " |
		cut -f2 -d' ' |
		head -1               # prefer first device in list
	)
	test -n "$_mp" && echo $_mp
}

require() {
	case "$1" in
	mounted)
		shift 1
		device=$1
		mountpoint=$2
		test -n "$mountpoint" || die "ERR480: usage: require mounted {partition-device} {mountpoint}"
		current=$(mount_point "$device")

		if test -z "$current"; then
			progress "0300" "Mounting '$device'..."
			io test -d "$mountpoint" || io mkdir -p "$mountpoint" &&
			io /bin/mount "$device" "$mountpoint" &&
			current=$(mount_point "$device")
		fi

		if test -n "$current"; then
			echo "$current"
			progress "0399" "The partition '$device' is mounted on '$current'."
			return 0
		else
			progress "0398" "'$device' could not be mounted."
			die "ERR591: Failed to mount '$device' on '$mountpoint'."
		fi
	;;
	unmounted)
		shift 1
		device=$1
		test -n "$device" || die "ERR481: usage: require unmounted {partition-device}"
		current=$(mount_point "$device")

		if test -n "$current"; then
			progress "0400" "Unmounting '$device'..."
			io /bin/umount "$device" &&
			current=$(mount_point "$device")
		fi

		if test -z "$current"; then
			progress "0499" "'$device' is unmounted."
			return 0
		else
			progress "0498" "'$device' could not be unmounted."
			die "ERR592: Failed to unmount '$device' from '$current'."
		fi
	;;
	nand)
		if ! $(on_nand); then
			die "ERR593: This command must only be run when mounted on the NAND"
		fi
	;;
	image-mounted)
		# try really, really hard to mount the image partition.
		if ! imagedir=$(require mounted "$(sdcard)p4" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
			if (format_partitions $(sdcard) p4); then
				imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4)
			fi
			if test -z "$imagedir"; then
				force_partitioning
				imagedir=$(require mounted $(sdcard)p4 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4)
			fi
		fi
		# if we get to here then we successfully remounted the image partition. if we don't the SD card
		# is hosed and there isn't much we can do.
		echo $imagedir
	;;
	large-tmp)
		if test "$(tmp_device)" = "tmpfs"; then
			imagedir="$(require image-mounted)" &&
			mkdir -p "${imagedir}/tmp" &&
			(
				# try to avoid cleaning an executing script or its dependencies
				physical=$(gnu_readlink -f "${RECOVERY_FACTORY_RESET}") &&
				find "${imagedir}/tmp" -type f |
				grep -v "^$physical" | while read f; do
					${RECOVERY_ENABLE_TMP_CLEANUP:-false} && rm "$f"
				done || true
			) ||
			# io mount -o bind "${imagedir}/tmp" /tmp &&
			die "ERR594: Failed to mount image device on /tmp."
		fi
		echo "${imagedir}/tmp"
		# if we get to here, we have a large tmp device, or at least one not on tmpfs
	;;
	*)
		die "ERR482: usage: require mounted {partition-device} [ {preferred-mount-point} ] | unmounted {partition-device} ."
	;;
	esac
}

varname() {
	var=$1

	case "$var" in
	image)
		echo RECOVERY_IMAGE
	;;
	prefix)
		echo RECOVERY_PREFIX
	;;
	github)
		echo RECOVERY_GITHUB
	;;
	enable-script-phases)
		echo RECOVERY_ENABLE_SCRIPT_PHASES
	;;
	enable-factory-reset-io)
		echo RECOVERY_ENABLE_SPHERE_IO_FACTORY_RESET
	;;
	enable-sphere-io)
		echo RECOVERY_ENABLE_SPHERE_IO
	;;
	enable-reboot-on-repartitioning)
		echo RECOVERY_ENABLE_REBOOT_ON_REPARTITIONING
	;;
	enable-reboot)
		echo RECOVERY_REBOOT
	;;
	archive-delegation-rule)
		echo RECOVERY_ARCHIVE_DELEGATION_RULE
	;;
	RECOVERY_*)
		echo "$var"
	;;
	*)
		echo ""
		return 1
	;;
	esac

}

_set() {
	var=$1
	value=$2

	if test -n "$var"; then
		progress "0501" "Mounting image partition."
		if ! imagedir=$(require mounted "$(sdcard)p4" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4); then
			progress "0502" "Image partition "$(sdcard)p4" cannot be mounted. Reformatting..."
			format_partitions $(sdcard) p4
			progress "0503" "Image partition formatted. Remounting..."
			imagedir=$(require mounted "$(sdcard)p4" ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p4) || exit $?
			progress "0504" "Image mounted."
		fi
		test -f "${imagedir}/recovery.env.sh" || touch "${imagedir}/recovery.env.sh"
	fi

	case "$var" in
	wpa-psk)
		shift 1
		test $# -eq 2 || die "ERR486: usage: set wpa-psk {ssid} {psk}"
		patch wpa "$@"
		return 0
	;;
	*)
		varname=$(varname "$var")
		test -n "$varname" || die "ERR485: usage:
set {varname} {value...}

where {varname} {value...} is one of:
	image {image-dir}
	prefix {url-prefix}
	wpa-psk {ssid} {psk}
	enable-script-phases [true|false]
	enable-factory-reset-io [true|false]
	enable-sphere-io [true|false]
	enable-reboot-on-repartitioning [true|false]
	enable-reboot [true|false]
"
	;;
	esac

	sed -i "/^export ${varname}=.*/d;" "${imagedir}/recovery.env.sh" &&
	echo "export $varname=$value;" >> "${imagedir}/recovery.env.sh" ||
	die "ERR596: Failed to set '$var'."
}

_patch() {

	type=$1
	test $# -ge 1 && shift 1
	case "$type" in
	wpa)
		if $(on_nand); then
			ssid=$1
			password=$2
			cat >$(wpa_supplicant physical) <<EOF
ctrl_interface=/var/run/wpa_supplicant
update_config=1
EOF

			if test -n "$password"; then
				cat >>$(wpa_supplicant physical) <<EOF

network={
       ssid="$ssid"
       scan_ssid=1
       psk="$password"
       key_mgmt=WPA-PSK
}
EOF
			fi
			if ! test -L /etc/wpa_supplicant.conf; then
				ln -sf "$(wpa_supplicant physical)" /etc
			fi &&
			(ifup wlan0 || echo "ifup wlan0 failed." 1>&2) &&
			(wpa_cli reconfigure || echo "wpa_cli reconfigure failed." 1>&2)
		else
			die "ERR490: This command cannot be run while running the sdcard image."
		fi
	;;
	opkg)
		if $(on_nand); then
			if ! grep "src all http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/all" /etc/opkg/opkg.conf > /dev/null 2>&1; then
cat >> /etc/opkg/opkg.conf <<EOF
src all http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/all
src cortexa8hf-vfp-neon-3.8 http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/cortexa8hf-vfp-neon-3.8
src varsomam33 http://osbuilder01.ci.ninjablocks.co/yocto/deploy/ipk/varsomam33
EOF
			fi
		else
			die "ERR491: This command cannot be run while running the sdcard image."
		fi
	;;
	eth2)
		if (require nand); then
			if ! grep "^iface eth2 inet dhcp" /etc/network/interfaces &>/dev/null; then
				progress "0101" "Patching eth2."
				cat >> /etc/network/interfaces <<EOF

iface eth2 inet dhcp
EOF
				progress "0103" "Patched eth2."
			else
				progress "0102" "Patch already applied (eth2)."
			fi
			ifup eth2
		else
			false
		fi
	;;
	nand)
	if $(on_nand); then
			/opt/ninjablocks/factory-reset/bin/recovery.sh generate-env ubuntu_armhf_trusty_norelease_sphere-unstable http://odroid:8000/latest > /var/volatile/run/media/${RECOVERY_SDCARD}p4/recovery.env.sh &&
			if ! test -e /etc/wpa_supplicant.conf; then
				patch wpa
			fi
			if ! test -L /etc/wpa_supplicant.conf; then
				cp /etc/wpa_supplicant.conf /var/run &&
				ln -sf $(wpa_supplicant physical) /etc/wpa_supplicant.conf
			fi &&
			patch opkg &&
			opkg update &&
			opkg install e2fsprogs-mke2fs &&
			echo ok || echo failed
	else
		die "ERR492: This command cannot be run while running the sdcard image."
	fi
	;;
	recovery.sh)
		cd $(dirname "$0") &&
		curl -s ${RECOVERY_PREFIX}/recovery.sh > recovery.sh.tmp &&
		mkdir -p ../etc &&
		chmod ugo+x recovery.sh.tmp &&
		sha1 < "$(pwd)/recovery.sh.tmp" &&
		mv recovery.sh.tmp recovery.sh &&
		timestamp > ../etc/timestamp &&
		echo "Updated." 1>&2 ||
		die "ERR496: Failed to update recovery script"
	;;
	*)
		die "ERR493: usage: patch opkg|wpa [{ssid} {psk}]|nand"
	;;
	esac
}

get() {
	var=$1
	test -n "$var" || die "ERR497: usage get {var}"
	if varname=$(varname "$var"); then
		env | sed -n "s/^${varname}=//p"
	fi
}

_env() {
	env | sed -n "/^RECOVERY/p" | sort
}

patch() {
	( with_rw _patch "$@" ) || exit $?
}

shell() {
	PATH=${RECOVERY_FACTORY_RESET}/bin:$PATH
	cd ${RECOVERY_FACTORY_RESET}
	if test $# -gt 0; then
		exec "$@"
	else
		export PS1="\\h:\\W \\u\$ "
		exec sh
	fi
}

timestamp() {
	date -u +%Y%m%dT%H%M%S
}


pack() {
	output=$1
	test -n "$output" || die "ERR499: usage: pack {packed-file}"

	test -f "$(cd $(dirname "$0")/..; pwd)/doc/recovery.md" || die "ERR498: 'pack' must be run with bin/recovery.sh in a factory reset tree."
	timestamp=$(timestamp)
	mkdir -p ${RECOVERY_FACTORY_RESET}/etc
	echo "$timestamp" > "${RECOVERY_FACTORY_RESET}/etc/timestamp"

cat >"$output" <<EOFP
#!/bin/sh
export TMPDIR=\${TMPDIR:-/tmp}
mkdir -p ${TMPDIR}
set -e
sha1=\$(cat "\$0" | openssl sha1 | cut -f2 -d' ')
export RECOVERY_SCRIPT_TIMESTAMP=$timestamp;
export RECOVERY_PACKED_SCRIPT_SHA1=\$sha1;
test -e \${TMPDIR}/tree/\${sha1} && rm -rf \${TMPDIR}/tree/\${sha1}
mkdir -p \${TMPDIR}/tree/\${sha1}
mkdir -p \${TMPDIR}/by-timestamp/
(
cat <<EOF
$(tar -C ${RECOVERY_FACTORY_RESET} -czf - . | openssl base64)
EOF
) | openssl base64 -d | tar -C \${TMPDIR}/tree/\${sha1} -zxf -
! test -e \${TMPDIR}/by-timestamp/\$RECOVERY_SCRIPT_TIMESTAMP || rm \${TMPDIR}/by-timestamp/\$RECOVERY_SCRIPT_TIMESTAMP
ln -sf ../tree/\$sha1/ \${TMPDIR}/by-timestamp/\$RECOVERY_SCRIPT_TIMESTAMP
export PATH=\${TMPDIR}/by-timestamp/\$RECOVERY_SCRIPT_TIMESTAMP/bin:\$PATH;
exec \${TMPDIR}/by-timestamp/\$RECOVERY_SCRIPT_TIMESTAMP/bin/recovery.sh "\$@"
EOFP
	chmod ugo+x "$output"
	echo "$output"
}

unpack() {
	cd $(dirname $0)/..; pwd
}

with() {
	case "$1" in
	fixed-script-phases)
		shift 1
		RECOVERY_ENABLE_SCRIPT_PHASES=false
		"$@"
	;;
	io-trace)
		shift 1
		(
				RECOVERY_IO_REDIRECT=trace_io${RECOVERY_IO_REDIRECT:+ }${RECOVERY_IO_REDIRECT}
				"$@"
		) || exit $?
	;;
	large-tmp)
		shift 1
		if
			imagedir=$(require image-mounted) &&
			mkdir -p "${imagedir}/tmp" &&
			mount -o bind "${imagedir}/tmp" /tmp; then
			( "$@" )
			rc=$?
			umount /tmp || rc=$?
			test $rc -eq 0 || exit $rc
		else
			die "ERR568: Cannot mount '${imagedir}/tmp' on /tmp."
		fi
	;;
	*)
		die "ERR407: usage: with block|large-tmp"
	;;
	esac
}

# repack the current tree, then unpack it and report the location of the new unpack tree
repack() {
	$(pack ${TMPDIR}/repack.$$) unpack
	test -f "${TMPDIR}/repack.$$" && rm "${TMPDIR}/repack.$$"
}

discover_tar() {
	discover_file $(url file .tar)
}

# Search for a recovery file on p4 and any available USB hard drive.
# if one exists on both the SDCARD and the USB drive, then prefer
# the version on the USB drive.
#
# Prefer higher number partitions over lower numbered partitions.
discover_file() {
	name=$1
	result=$(
		(
			echo /dev/${RECOVERY_SDCARD}p4 &&
			find /dev -maxdepth 1 -type b -name '/dev/sda[0-9]*' || true
		) |
		while read dev; do
			mp=$(require mounted "$dev" ${RECOVERY_MEDIA}/$(basename "$dev")) &&
			echo $mp
		done |
		while read mp; do
			find "$mp" -type f -maxdepth 1 -name "$name"
		done |
		while read f; do
				( check_file "$f" ) && echo $f
		done | tail -1
	) &&
	test -n "$result" &&
	echo "$result"
}

#
# Looks at all available recovery scripts, and chooses the youngest one.
#
# /opt/ninjablocks/bin/recovery.sh on NAND
# /opt/ninjablocks/bin/recovery.sh on SDCARD
# contents of recovery tar on SDCARD
#
choose_latest() {

	progress "0901" "Looking for latest recovery script in /opt/ninjablocks/bin..."
	if test -x /opt/ninjablocks/factory-reset/bin/recovery.sh &&
		test -f /opt/ninjablocks/factory-reset/etc/timestamp; then
		timestamp=$(cat /opt/ninjablocks/factory-reset/etc/timestamp)
		progress "0903" "Found executeable script in /opt/ninjablocks/factory-reset/bin ($timestamp)."
		# link the NAND image as the primordial tree.
		mkdir -p "${TMPDIR}/by-timestamp"
		ln -sf "/opt/ninjablocks/factory-reset" "${TMPDIR}/by-timestamp/${timestamp}"
	else
		# this could be bad.
		progress "0902" "Could not find factory-reset tree in /opt/ninjablocks/factory-reset."
	fi

	progress "0910" "Checking for root partition..."
	if root=$(require mounted $(sdcard)p2 ${RECOVERY_MEDIA}/${RECOVERY_SDCARD}p2); then
		if test -x $root/opt/ninjablocks/bin/recovery.sh; then
			progress "0913" "Found executeable script in /opt/ninjablocks/bin of $(sdcard)p2"
			found=$(with large-tmp sh $root/opt/ninjablocks/bin/recovery.sh unpack)
			progress "0915" "Unpacked recovery script as '$found' ($(cat "$found/etc/timestamp"))."
		else
			progress "0912" "Could not find executeable script in /opt/ninjablocks/bin of $(sdcard)p2"
		fi
	else
		progress "0911" "Could not mount image partition..."
	fi

	progress "0920" "Checking recovery tars on image partition..."
	if tar=$(discover_tar); then
		image=$(gnu_basename "$tar" "$(url suffix .tar)") &&
		script="${image}$(url suffix .sh)" &&
		adjacent="$(dirname "$tar")/$script" &&
		found="" &&
		packed="" &&
		if test -f "$adjacent" && (check_file "$adjacent"); then
			progress "0923" "Found recovery script next to '$tar'..."
			packed="$adjacent"
		else
			progress "0924" "Extracting recovery script from '$tar'..." &&
			if tar -C ${TMPDIR} -xf "${tar}" "${script}" "${script}.sha1"; then
				progress "0926" "Extraction of '$script' from '${tar}' was successful." &&
				if (check_file "${TMPDIR}/${script}"); then
					packed="${TMPDIR}/${script}"
				else
					false
				fi
			fi
		fi &&
		if test -n "$packed"; then
			progress "0927" "Unpacking '${packed}'..." &&
			found=$(with large-tmp "$packed" unpack) &&
			progress "0928" "Unpacked recovery script as '$found' ($(cat "$found/etc/timestamp"))."
		fi &&
		test -n "$found" || progress "0928" "Unable to extract recovery script from next to or within '$tar'"
	fi

	latest="$(
		find ${TMPDIR}/by-timestamp -maxdepth 1 -type l |
		while read d; do
			test -f $d/bin/recovery.sh && echo $d
		done |
		sort |
		tail -1
	)"
	if test -n "$latest/bin/recovery.sh"; then
		progress "0949" "Launching '$latest/bin/recovery.sh' ..."
		exec sh $(choose_script "$latest/bin/recovery.sh") "$@"
	else
		# this is best we can do, so use it
		progress "0948" "Could not find any recovery scripts. Launching '$0'..."
		exec sh "$0" "$@"
	fi
}

tmp_device() {
	df "${TMPDIR:-/tmp}" | cut -f1 -d' ' | sed -n 2p
}

with_rw() {
        rc=0 &&
        mode=$(cat /proc/self/mounts | egrep "^(/dev/root|ubi0:rootfs)" | cut -f4 -d' ' | cut -f1 -d,) &&
        test "$mode" = "rw" || mount -oremount,rw / &&
        "$@" || rc=$?
        ! test "$mode" = "ro" || mount -oremount,ro / && exit $rc
}

main() {

	mkdir -p ${TMPDIR}
	mkdir -p ${RECOVERY_MEDIA}

	if "$(on_nand)" &&
		test "$(tmp_device)" = "tmpfs" &&
		! ${RECOVERY_CHROOT};
	then
		export TMPDIR=$(require large-tmp) ||
		die "ERR501: Unable to mount large temp device - abandon all hope, ye who enter here!"
	fi

	if "$(on_nand)"; then
		imagedir=$(require image-mounted) &&
		if test -f "${imagedir}/recovery.env.sh"; then
			 . "${imagedir}/recovery.env.sh" || true
		fi &&
		if test -f "/etc/factory.env.sh"; then
			 . "/etc/factory.env.sh" || true
		fi
	fi

	cmd=$1
	case "$cmd" in
	blank-image)
		shift 1
		confirmed_action blank_image "$@"
	;;
	write-partition-table)
		shift 1
		confirmed_action write_partition_table "$@"
	;;
	format-partitions)
		shift 1
		confirmed_action format_partitions "$@"
	;;
	check-partition-table)
		shift 1
		check_partition_table "$@"
	;;
	confirmation-code)
		shift 1
		confirmation_code "$@"
	;;
	partition-sha1sum)
		shift 1
		partition_sha1sum "$@"
	;;
	bytes|cylinders|heads|sectors)
		"$@"
	;;
	boot-mb)
		shift 1
		boot_mb "$@"
	;;
	boot-cylinders)
		shift 1
		boot_cylinders "$@"
	;;
	sector-size)
		sector_size
	;;
	partition-table)
		partition_table
	;;
	generate-env)
		shift 1
		generate_env "$@"
	;;
	recovery-with-network)
		shift 1
		setup
		recovery_with_network "$@"
	;;
	recovery-without-network)
		shift 1
		setup
		recovery_without_network "$@"
	;;
	download)
		shift 1
		setup
		download "$@"
	;;
	factory-reset)
		shift 1
		export RECOVERY_ENABLE_SPHERE_IO=${RECOVERY_ENABLE_SPHERE_IO_FACTORY_RESET}
		setup
		factory_reset "$@" 2>&1 | tee ${TMPDIR:-/tmp}/factory-reset.log
	;;
	factory-setup-assistant)
		shift 1
		setup
		factory_setup_assistant "$@"
	;;
	image-from-mount-point)
		shift 1
		setup
		image_from_mount_point "$@"
	;;
	url)
		shift 1
		setup
		url "$@"
	;;
	patch)
		shift 1
		setup
		patch "$@"
	;;
	on-nand)
		shift 1
		on_nand "$@"
	;;
	recover-boot)
		shift 1
		setup
		recover_boot "$@"
	;;
	recover-data)
		shift 1
		setup
		recover_data "$@"
	;;
	mount-point)
		shift 1
		mount_point "$@"
	;;
	messages)
		shift 1
		messages "$@"
	;;
	require)
		shift 1
		setup
		require "$@"
	;;
	setup-assistant-path)
		shift 1
		setup
		setup_assistant_path "$@"
	;;
	set)
		shift 1
		setup
		_set "$@"
	;;
	tool-path)
		shift 1
		tool_path "$@"
	;;
	pack)
		shift 1
		pack "$@"
	;;
	unpack)
		shift 1
		unpack "$@"
	;;
	shell)
		shift 1
		shell "$@"
	;;
	choose-latest)
		shift 1
		choose_latest "$@"
	;;
	choose-script)
		shift 1
		choose_script "$@"
	;;
	sdcard)
		shift 1
		sdcard "$@"
	;;
	repack)
		shift 1
		repack "$@"
	;;
	force-partitioning)
		shift 1
		confirmed_action force_partitioning "$@"
	;;
	tmp-device)
		shift 1
		tmp_device "$@"
	;;
	with)
		shift 1
		setup
		with "$@"
	;;
	get)
		shift 1
		get "$@"
	;;
	env)
		shift 1
		_env "$@"
	;;
	recovery-sh-timestamp)
		shift 1
		recovery_sh_timestamp "$@"
	;;
	resolve-delegation)
		shift 1
		resolve_delegation "$@"
	;;
	discover-tar)
		shift 1
		discover_tar "$@"
	;;
	*)
		usage
	;;
	esac
}

main "$@"
