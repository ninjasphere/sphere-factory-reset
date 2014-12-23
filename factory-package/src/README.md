Ninja Sphere Factory Build Package
==================================

This directory contains the media required to support the construction of Ninja Spheres by the Innocomm factory.

A manifest of all files is found in the file called factory.manifest. This file contains the SHA1 hash of each file in the distribution and can be used to check that a complete set of files with known contents has been received.

The subdirectories are:

01-SOM
------
	The files required to flash a SOM with a boot loader that can be used to put the SOM into DFU mode.

02-NAND
-------
	The files required to load a recovery image into the system NAND using the DFU tool and process. These files
	should be used with the dfu-util tool.

03-SDCARD
---------
	The files required to perform a factory reset of a built sphere. These files should boot copied into the root
	directory of a FAT partition on a USB memory stick.

04-TEST
-------
	The files required to perform a factory test of a factory reset sphere.


Process Requirements
====================

01-SOM
------
Requirements:
	1. FTDI cable
	2. OSX or Linux host with expect and picocom software installed
	3. Micro SD Card (>1GB) with formatted boot partition.
	4. NinjaSphere DevKit modified to boot to SDCARD
	5. Supply of blank 512MB SOMs

02-NAND
-------
Requirements:
	1. Mini-USB cable
	2. OSX, Linux or Windows host with dfu-util 0.7 installed
	3. Supply of 512MBs SOMs to which '01-SOM' process has been applied

03-SDCARD
---------
Requirements:
	1. Assembled Ninja Sphere with blank 4GB SDCards installed and SOMs to which '02-NAND' process has been applied.
	2. USB thumbdrive with 1GB FAT partition containing the contents of the 03-SDCARD directory and all subdirectories

04-TEST
-------
Requirements:
	1. Assembled NinjaSphere to which '03-SDCARD' has been applied
	2. Windows Host with contents of ninjasphere-factory-test-windows-*.zip unpacked.


Process Steps
=============

01-SOM
------

Setup Steps
-----------
	1. Setup a Devkit which has been modified to boot to the SDCARD

	2. Orient the board

		Orient the board so that the EtherNet jack is to the right, the SOM slot to the left, the power jack at the top

	3. Connect an FTDI cable to the USB port on the host machine and the FTDI pins next to the NetVox chip on the devkit.

		a. In defaul orientation, the FTDI cable should be connected to the 6-pin FTDI connector on the bottom of the board
		b. the (black) ground lead of the FTDI cable should be connected to the pin closest to the Netvox module

	4. Use a Linux or OSX host to write an image directly onto a Micro SDCARD

		Linux:

		dd if=factory-boot-com.img.gz of=/dev/replace-me-with-the-correct-device bs=16M

		OSX:

		dd if=factory-boot-com.img.gz of=/dev/replace-me-with-the-correct-device bs=16m

	5. Install the formatted SDCARD in the DevKit's Micro SDCARD slot

Per Unit Steps
--------------
	1. Confirm that the devkit power is off

	2. Insert blank SOM into slot
	3. Start the expect script on the Linux host

		expect factory-nand.expect --serial /dev/{name-of-your-FTDI-device}

	4. Power on the devkit
	5. Wait for the expect script to finish with output like:

U-Boot 2013.01.01 (Apr 03 2014 - 23:56:21)

I2C:   ready
DRAM:  256 MiB
WARNING: Caches not enabled
Variscite  AM33 SOM revision 1.3 detected
NAND:  128 MiB
MMC:   OMAP SD/MMC: 0, OMAP SD/MMC: 1
*** Warning - bad CRC, using default environment

Net:   <ethaddr> not set. Validating first E-fuse MAC
cpsw
Hit any key to stop autoboot:  0
VAR_AM335X# mmc rescan
VAR_AM335X# nand erase 0x0 0x280000

NAND erase: device 0 offset 0x0, size 0x280000
Erasing at 0x260000 -- 100% complete.
OK
VAR_AM335X# mmc rescan
VAR_AM335X# set mmc_dev 0
VAR_AM335X# fatload mmc ${mmc_dev} ${loadaddr} NAND-MLO
reading NAND-MLO
99928 bytes read in 20 ms (4.8 MiB/s)
VAR_AM335X# nand write ${loadaddr} 0x0 0x20000

NAND write: device 0 offset 0x0, size 0x20000
 131072 bytes written: OK
VAR_AM335X# nand write ${loadaddr} 0x20000 0x20000

NAND write: device 0 offset 0x20000, size 0x20000
 131072 bytes written: OK
VAR_AM335X# nand write ${loadaddr} 0x40000 0x20000

NAND write: device 0 offset 0x40000, size 0x20000
 131072 bytes written: OK
VAR_AM335X# nand write ${loadaddr} 0x60000 0x20000

NAND write: device 0 offset 0x60000, size 0x20000
 131072 bytes written: OK
VAR_AM335X# fatload mmc ${mmc_dev} ${loadaddr} NAND-u-boot.img
reading NAND-u-boot.img
376832 bytes read in 49 ms (7.3 MiB/s)
VAR_AM335X# nand write ${loadaddr} 0xc0000 0x100000

NAND write: device 0 offset 0xc0000, size 0x100000
 1048576 bytes written: OK
VAR_AM335X#


 DONE. Flash OK




	6. Power off the devkit
	7. Remove the formatted SOM from the slot.
	8. Repeat by going to step 2

02-NAND
-------

Setup Steps
-----------
	1. Setup a Devkit which HAS NOT been modified to boot to the SDCARD

	2. Remove any SDCARD from the devkit

	3. Orient the board

		Orient the board so that the EtherNet jack is to the right, the SOM slot to the left, the power jack at the top.

		In this orientation, the reset button is the button closest to the top of the board (furthest away from the SDCARD).

	4. Connect a mini-USB cable to the USB port on the Linux host machine to the mini-USB port on right hand side of the devkit

Per Unit Steps
--------------
	1. Confirm the devkit power is off

	2. Insert a formatted SOM into slot
	3. Press and hold down the reset button on the devkit
	4. Turn the devkit power on
	5. Release the reset buton on the devkit after 2 seconds.

	6. On the Linux host, confirm that the device has appeared in the list of dfu devices (dfu-util -l)

		greywedge2:02-NAND jonseymour (1)$ dfu-util -l

		dfu-util 0.7

		Copyright 2005-2008 Weston Schmidt, Harald Welte and OpenMoko Inc.
		Copyright 2010-2012 Tormod Volden and Stefan Schmidt
		This program is Free Software and has ABSOLUTELY NO WARRANTY
		Please report bugs to dfu-util@lists.gnumonks.org

		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=0, name="NAND.SPL"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=1, name="NAND.SPL.backup1"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=2, name="NAND.SPL.backup2"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=3, name="NAND.SPL.backup3"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=4, name="NAND.u-boot-spl-os"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=5, name="NAND.u-boot"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=6, name="NAND.u-boot-env"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=7, name="NAND.u-boot-env.backup1"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=8, name="NAND.kernel"
		Found DFU: [0403:bd00] devnum=0, cfg=1, intf=0, alt=9, name="NAND.rootfs"

	7. Run:

		./02-dfu.sh flash 8031f9f703f92daf410be9e0c8ee3732cc0de493

	When the flashing is complete....

	8. Remove the NAND flashed SOM from the slot
	9. Repeat by going to step 2.

03-SDCARD
---------

Setup Steps
-----------
	1. Format a USB thumb drive with 1GB of space with a FAT file system
	2. Copy all the files and directories into 03-SDCARD onto the root partition of the USB thumbdrive

Per Unit Steps
--------------
	1. Confirm power to the sphere is off and all cables and peripherals are disconnected.

	2. Insert the USB thumb drive into the slot of the sphere
	3. Press and hold the reset button at the base of the sphere
	4. Insert the power cord
	5. Wait 5 seconds
	6. Release the reset button

	7. Wait 60 seconds for LED status codes to appear

		The process will continue for at least 10 minutes until 9999 is displayed.
		The system will then reboot to the SDCARD and install firmware. This process takes 2-3 minutes.
		The system will then reboot to the SDCARD a second time and should eventually display a phone icon.

	8. Remove power from the sphere.
	9. Remove the USB from the sphere.
   10. Repeat the process for a new sphere at step 2.

04-TEST
-------
Setup Steps
-----------
	1. Unpack zip files in the 04-TEST directory into directory on a Windows machine (e.g. c:\NinjaFactory\04-TEST)
	2. For each operator:

		a. run the test_run.bat file
		b. enter the COM port to be used for this instance (e.g. COM10, COM11 or whatever)
		c. scan the operator id
		d. scan the serial id of the first sphere

	3. Connect the mini-USB cable to the sphere under test
	4. Connect the power cable to the sphere under test
	5. Wait for the 10 symbol to appear
	6. Perform tests 10, 20, 30, 40 and 50

REVISION HISTORY
----------------
1.0.1 - Updated process notes.
1.0.0 - Initial release