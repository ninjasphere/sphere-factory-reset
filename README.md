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
built on 6 Dec 2014 or later.

On subsequent factory resets, you should be able to re-use the configuration done by this process.

1. Start a screen session to the mini-USB tty device.
1. Login as root (no password).

Run the following commands:

	/var/volatile/run/media/mmcblk0p2/opt/ninjablocks/factory-reset/bin/recovery.sh patch wpa {SSID} {passphrase}
	ifup wlan0
    /var/volatile/run/media/mmcblk0p2/opt/ninjablocks/factory-reset/bin/recovery.sh patch nand

INITIATE FACTORY RESET
----------------------
1. Boot the sphere with current SD card
2. After boot is complete, hold down the reset button until the led matrix turns RED
3. Release the reset button
4. In this phase, the sphere will do any necessary network downloads and then nuke the boot partition to force a NAND boot
5. After the NAND boot has completed screen to the sphere via the mini-USB port
6. login as root
7. Run /opt/ninjablocks/factory-reset/bin/recovery.sh factory-reset to complete the process.

RESERVED NAMESPACE
==================
This package reserves /opt/ninjablocks/factory-reset for its own purposes both in the NAND and SDCARD images.
