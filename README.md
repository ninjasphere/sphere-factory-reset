NAME
=====
sphere-factory-reset - builds factory reset components

DESCRIPTION
===========
This package build a debian package containing all the NAND image components required to support the factory reset process. These are
extracted from the various source projects that contain the components.

The contents of this package are fed into the yocto NAND image build process using manual methods.

FACTORY RESET FROM NAND
=======================

START A WEB SERVER ON ODROID TO SERVE THE IMAGES
-------------------------------------------------
Login to odroid, and run:

    cd /images/sphere-unstable
    python -m SimpleHTTPServer

This will run on port 8000 of odroid.

FLASH NAND
----------
1. follow steps in https://github.com/ninjablocks/factory-scripts/blob/master/factory-boot-som/README.md and
https://github.com/ninjablocks/factory-scripts/blob/master/NAND-image/README.md

BOOT TO NAND
------------
1. take the power cord out and mini-usb cords of the sphere
2. hold the reset button down
3. reinsert the power cord
4. wait until the worms appear, then disappear and then another 5 seconds.
5. release the reset button
6. connect the mini-USB cable

INTERIM RECONFIGURATION OF NAND
-------------------------------
This step needs to be done once to configure the NAND and assumes you have an SD card that has been flashed with an image
built on 6 Dec 2014 or later. This stepp will not be required once the factory reset logic is burned into the NAND.

1. Start a screen session to the mini-USB tty device.
1. Login as root (no password).

Run the following commands:

	export PATH=/var/volatile/run/media/mmcblk0p2/opt/ninjablocks/factory-reset/bin:$PATH
	recovery.sh patch wpa {SSID} {passphrase}
	ifup wlan0
    recovery.sh patch nand

On subsequent factory resets, you won't need to repeat the above steps.

INITIATE FACTORY RESET
----------------------
1. Boot the sphere with current SD card
2. After boot is complete, hold down the reset button until the led matrix turns RED
3. Release the reset button
4. In this phase, the sphere will do any necessary network downloads and then nuke the boot partition to force a NAND boot
5. After the NAND boot has completed screen to the sphere via the mini-USB port
6. login as root
7. Run /opt/ninjablocks/factory-reset/bin/recovery.sh factory-reset to complete the process.

VARIANTS
========
NAND only reset
---------------
1. Boot to NAND as per "BOOT TO NAND"
2. Run /opt/ninjablocks/factory-reset/bin/recovery.sh factory-reset
3. Use app to provide network credtials, when prompted.

Forcing latest recovery image
-----------------------------
During NAND only resets, the system will use an available recovery tar if there is one. To force it to use a network
download to fetch the latest one, run the following commands:

	mkdir -p /tmp/image
	mount /dev/mmcblk0p4 /tmp/image
	rm /tmp/image/*.tar

To change the network location
------------------------------
Configure the URL prefix for the recovery media:

	mkdir -p /tmp/image
	mount /dev/mmcblk0p4 /tmp/image

	echo "export RECOVERY_PREFIX={the-url-prefix};" >> /tmp/image/recovery.env.sh

To change the name of the recovery image
------------------------------
Configure the name of the recovery image:

	mkdir -p /tmp/image
	mount /dev/mmcblk0p4 /tmp/image

	echo "export RECOVERY_IMAGE=ubuntu_armhf_trusty_norelease_sphere-unstable;" >> /tmp/image/recovery.env.sh

RESERVED NAMESPACE
==================
This package reserves /opt/ninjablocks/factory-reset for its own purposes both in the NAND and SDCARD images.
