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

FLASH NAND
----------
1. follow steps in https://github.com/ninjablocks/factory-scripts/blob/master/factory-boot-som/README.md and
https://github.com/ninjablocks/factory-scripts/blob/master/NAND-image/README.md

BOOT TO NAND
------------
1. take the power cord out and mini-usb cords of the sphere
2. hold the reset button down
3. reinsert the power cord
4. wait until the worms appear, then disappear
5. release the reset button
6. connect the mini-USB cable

INTERIM RECONFIGURATION OF NAND
-------------------------------
This step assumes you have up to date SD card

1. Start a screen session to the usb tty device.
1. Login as root (no password).

Run the following commands:

    mount -oremount,rw / ;
    mkdir -p /opt/ninjablocks/factory-reset ;
    (cd /var/volatile/run/media/mmcblk0p2/opt/ninjablocks/factory-reset; tar -cf - .) | (cd /opt/ninjablocks/factory-reset; tar -xf -) ;
    cat >/var/volatile/run/media/mmcblk0p4/recovery.env.sh <<EOF
    export RECOVERY_IMAGE=ubuntu_armhf_trusty_norelease_sphere-unstable
    export RECOVERY_PREFIX=http://odroid:8000/{image-name}
    EOF

START A WEB SERVER ON ODROID TO SERVE THE IMAGES
-------------------------------------------------
Login to odroid, and run:

    cd /images/sphere-unstable
    python -m SimpleHTTPServer

RUN FACTORY RESET
-----------------
If the webserver is not available, then copy:

    ubuntu_armhf_trusty_norelease_sphere-unstable-recovery.tar.sha1
    ubuntu_armhf_trusty_norelease_sphere-unstable-recovery.tar

into /var/volatile/run/media/mmcblk0p4. Otherwise, run:

    rm /var/volatile/run/media/mmcblk0p4/*.tar

Then run:

    /opt/ninjablocks/factory-reset/bin/reset-helper.sh factory-reset

Disconnect the mini USB cable.

Reboot the sphere.

RESERVED NAMESPACE
==================
This package reserves /opt/ninjablocks/factory-reset for its own purposes both in the NAND and SDCARD images.
