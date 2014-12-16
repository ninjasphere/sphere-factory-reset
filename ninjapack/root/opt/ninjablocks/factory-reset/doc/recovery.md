NAME
====
recovery.sh - NinjaSphere recovery script.

COMMANDS
========
blank-image {confirmation-code} {file}
------------------
Create a blank image of 'bytes' size. The blank image includes a partition table.

bytes
-----
The size of the full SDCARD image in bytes. Derived from 'cylinders', 'sectors', 'heads' and 'sector-size'.

check-partition-table {block-device}
------------------------------------
Check that the partition table on the specified block device has the expected hash or die otherwise.

choose-latest
-------------
Search locally for the youngest recovery script we have, then use that one.

confirmation-code {args...}
---------------------------
Calculate a confirmation code for the remaining arguments. The output of this command can be used with
destructive sub-commands that require a confirmation code to proceed.

cylinders
---------
The number of cylinders in the image.

download recovery-script
------------------------
Download the latest copy of the recovery script to /tmp and output the name to stdout.

download git-recovery-script
------------------------
Download the latest copy of the recovery script from git to /tmp and output the name to stdout.

factory-reset
-------------
Initiate the factory reset.

If running from an SD card boot, this command will attempt to update the recovery media from the network and then force
a NAND boot by zero'ing out the boot partition. The sphere will then reboot from the NAND and complete the factory reset
process.

If running from the NAND boot, this command will verify that recovery media is available locally. If there is no recovery media
available locally, this command will launch factory-setup-assistant to acquire network credentials and then download the recovery media. Once recovery media is available, the boot, root and data partitions will be reformatted and re-imaged.

factory-setup-assistant
-----------------------
Launch the sphere-setup-assistant in factory reset mode in order to obtain a network connection.

format-partitions {confirmation-code} {block-device} p{partition#}...
---------------------------------------------------------------------
Format the specified partitions (p1, p2, p3 or p4) on the specified block device.

generate-env {image-name} [{recovery-prefix}]
---------------------------------------------
Generate a customized recovery environment.

Use like:

	eval $(recovery.sh generate-env ubuntu_armhf_trusty_release_sphere-stable https://firmware.ninja.sphere/latest)

heads
-----
Number of heads in the image.

image-from-mount-point {mount-point}
------------------------------------
Derive the image name from the recovery image found in the specified directory.

on-nand
-------
Output true and exit with 0 if the root file system is the NAND partition. Output false and exit with non-zero otherwise.

messages
--------
List all the messages this script can generate.

mount-point {device}
--------------------
Answer the current mount point for the specified device.

partition-sha1sum {block-device}
--------------------------------
Report the sha1 sum of the partition table on the specified block device.

partition-table {block-device}
------------------------
Output the partition table on the specified block device.

patch nand
-----------
**INTERIM** Update the nand image with some recovery tools.

patch opkg
----------
**INTERIM** Update the NAND image to refer to the specified sources.

patch wpa {network-SSID} {network-passphrase}
---------------------------------------------
**INTERIM** Manually configure the /var/run/wpa_supplicant.conf file with WiFi network credentials

pack {sh-archive}
-----------------
Pack the factory reset scripts into a standalone shell archive.

recover-boot
------------
Restore the boot partition from the recovery tar on the image partition

recover-data
------------
Restore the data partition from the recovery tar on the image partition.

recovery-with-network
---------------------
Attempt to perform recovery, using the network to check for updates first. Fallback to recovery-without-network if recovery
media is available locally and the network is not available.

recovery-without-network
------------------------
Attempt to perform recovery, using the recovery tar found on the image partition.

require mounted {device} {preferred-mount-point}
------------------------------------------------
Require that the specified device is mounted or die in the attempt. The specified mountpoint will be used if the device is not already mounted. If the device is mounted, the existing mountpoint will be used.

The output of this command will be the actual mount point the device was successfully mounted or the empty string otherwise. The
exit code is zero if the mount point is not blank.

require unmounted {device}
--------------------------
Require that the specified device is unmounted or die in the attempt.

require image-mounted
---------------------
Requires that the image partition is mounted. If the image can't be mounted, then format it.

repack
------
Pack the current tree, then unpack it and report the new location.

sector-size
-----------
The size of sectors.

sectors
-------
The number of sectors.

set image {image-name}
----------------------
The name of the recovery image. This name matches the name of the recovery tar, less the -recovery.tar suffix.

set prefix {url-prefix}
-----------------------
The URL prefix of the recovery image.

set wpa-psk {ssid} {psk}
------------------------
Update the WiFi network credentials.

setup-assistant-path
--------------------
The setup assistant to be used.

shell [command args...]
-------------------
Starts a shell with the current working directory in the receiving script's tree with the receiving scripts tools
at the HEAD of the path. If a command and arguments are specified, the command is executed. Otherwise, the shell
remains active until the user types 'exit'.

tool-path {tool}
----------------
Outputs the absolute path of the specified tool.

unpack
------
This command does nothing other than report the top directory of the current FACTORY_RESET installation or fails if it is not one of these

url prefix|image|suffix|url
---------------------------
Answer part of a recovery url.

write-partition-table {confirmation-code} {block-device}
--------------------------------------------------------
Write a new partition table into the specified block device.