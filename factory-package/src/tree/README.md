Ninja Sphere Factory Build Package
==================================

This directory contains the media required to support the firmware flashing of Ninja Spheres by the Innocomm factory.

A manifest of all files is found in the file called factory.manifest. This file contains the SHA1 hash of each file in the distribution and can be used to check that a complete set of files with known contents has been received.

The subdirectories are:

01-SOM
------
	The files required to flash a SOM with a boot loader that can be used to put the SOM into DFU mode.

02-NAND
-------
	No longer used - all NAND flashing now done by 01-SOM.

03-SDCARD
---------
	The files required to perform a factory reset of a built sphere. These files should boot copied into the root
	directory of a FAT partition on a USB memory stick.

04-TEST
-------
	The files required to perform a factory test of a factory reset sphere.

each subdirectory corresponds to a step of the flashing process that needs to be conducted for each sphere (or components of each sphere) in the order that the process must be executed within the construction life cycle of a single sphere.

Hardware and Software Requirements
==================================

01-SOM
------
Requirements:
	1. FTDI cable (optional)
	2. FTDI device driver downloaded from here - http://www.ftdichip.com/Drivers/D2XX.htm (optional)
	3. A terminal program like PuTTY - http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
	4. Micro SD Card (>1GB) with formatted FAT boot partition of 100MB in size
	5. NinjaSphere DevKit modified to boot to SDCARD
	6. Supply of blank 512MB SOMs

02-NAND
-------
	No longer used - all NAND flashing now done by 01-SOM.

03-SDCARD
---------
Requirements:
	1. Assembled Ninja Sphere with blank 4GB SDCards installed and SOMs to which '02-NAND' process has been applied.
	2. USB thumbdrive with 1GB FAT partition containing the contents of the 03-SDCARD directory and all subdirectories thereof.

04-TEST
-------
Requirements:
	1. Assembled NinjaSphere to which the '03-SDCARD' process has been applied
	2. A windows host with contents of ninjasphere-factory-test-windows-*.zip unpacked.

Process Steps
=============

01-SOM
------

Setup Steps
-----------
	1. Setup a Devkit which has been modified to boot to the SDCARD

	2. Orient the board

		Orient the board so that the EtherNet jack is to the right, the SOM slot to the left, the power jack at the top

	3. (Optionally) Connect an FTDI cable to the USB port on the host machine and the FTDI pins next to the NetVox chip on the devkit.

		a. In default orientation, the FTDI cable should be connected to the 6-pin FTDI connector on the bottom of the board
		b. The (black) ground lead of the FTDI cable should be connected to the pin closest to the Netvox module
		c. Open PuTTY and create a serial connection to the FTDI device.

	4. Unpack the contents of the zip file in 01-SOM into the root partition of the SDCARD

	5. Install the formatted SDCARD in the DevKit's Micro SDCARD slot

Per Unit Steps
--------------
	1. Confirm that the devkit power is off
	2. Insert blank SOM into slot
	3. Power on the devkit
	4. Wait for 2 minutes
	5. After 2 minutes the LEDs on the Devkit should turn solid green.
	6. Power off the devkit
	7. Remove the formatted SOM from the slot
	8. Repeat the process for a new blank SOM by going to step 1

If the LEDs do not go green after 2 minutes, use PuTTY and the FTDI cable to review the output from the process.

02-NAND
-------
	No longer used - all NAND flashing now done by 01-SOM.

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
	1. Unpack the zip files in the 04-TEST directory into directory on a Windows machine (e.g. c:\NinjaFactory\04-TEST)

	2. For each operator:

		a. run the test_run.bat file
		b. enter the COM port to be used for this instance (e.g. COM10, COM11 or whatever)
		c. scan the operator id
		d. scan the serial id of the first sphere

	3. Connect the mini-USB cable to the sphere under test

	4. Connect the power cable to the sphere under test

	5. Wait for the 10 symbol to appear

	6. Perform tests 10, 20, 30, 40 and 50

	When the operator goes off shift, they should enter QUIT for the next serial number. This will cause the program to exit
	and allow the next operator to scan their own barcode.

REVISION HISTORY
----------------
* 1.0.13

	New version of ninjasphere-factory-test (1.0.18).
	Add a memory test (0006).
	Fix /etc/init/sphere-usb-packages.conf so that packages listed in usb-packages.manifest are installed during boot.
	Capture NAND SHA1 and kernel version string during test.
	Updated NAND (2f4b91d0de5f75db809dc1c814a1829de5354588).
	NAND update fixes problem since v1.0.9 where files were not copied from USB.

* 1.0.12

	Capture nand.sha1 in /etc/firmware-versions of NAND and SDCARD.
	Avoid reflashing ledmatrix firmware during SDCARD boot, if done during NAND boot.

* 1.0.11

	Refinements to process to use an SDCARD image which can flash the NAND from the factory jig.

* 1.0.2, et al

	Initial release.
