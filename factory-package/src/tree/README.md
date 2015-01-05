Ninja Sphere Factory Build Package
==================================

This directory contains the media required to support the firmware flashing of Ninja Spheres by the Innocomm factory.

Each subdirectory corresponds to a step of the flashing process that needs to be conducted for each sphere (or components of each sphere) in the order that the process must be executed within the construction life cycle of a single sphere.

A manifest of all files is found in the file called factory.manifest. This file contains the SHA1 hash of each file in the distribution and can be used to check that a complete set of files with known contents has been received.

The verifier-osx or verfier-win32.exe tools can be used to verify that you have received the correct versions of each file. Run the tools with an argument of --sha1-manifest=factory.manifest.

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

Hardware and Software Requirements
==================================

01-SOM
------
Requirements:

1. FTDI cable
2. FTDI device driver downloaded from here - http://www.ftdichip.com/Drivers/D2XX.htm (optional)
3. A terminal program like PuTTY - http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
4. Micro SD Card (>1GB) with formatted FAT boot partition of 100MB in size
5. NinjaSphere DevKit.
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
This process formats the NAND on the SOM with a boot loader and a recovery operating system used to assist with
factory resets. The process is driven by a specially crafted SDCARD which contains a boot loader which is configured
to copy files from the SDCARD into the NAND, followed by a NAND boot which turns green LEDs on when the process is complete.
If the process fails for any reason, the green LEDS will not be switched on and the SOM should be put aside for further
investigation.

Setup Steps
-----------
1. Setup a Devkit

2. Orient the board

	Orient the board so that the EtherNet jack is to the right, the SOM slot to the left, the power jack at the top

3. (Optionally) Connect an FTDI cable to the USB port on the host machine and the FTDI pins next to the NetVox chip on the devkit.

	a. In default orientation, the FTDI cable should be connected to the 6-pin FTDI connector on the bottom of the board

	b. The (black) ground lead of the FTDI cable should be connected to the pin closest to the Netvox module

4. Unpack the contents of the zip file in 01-SOM into the root partition of the SDCARD

5. Install the formatted SDCARD in the DevKit's Micro SDCARD slot

6. Install FTDI driver and PuTTY software on the Windows host machine to which the FTDI cable is attached.

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
This process is no longer used since all NAND flashing now done by the '01-SOM' process.

03-SDCARD
---------
This process performs a factory reset of the device using recovery media read from a USB key. This process requires a working
SOM that has been provisioned with a boot loader and recovery operating system as produced by the '01-SOM' process described
above. At the end of the process, the sphere's SDCARD will be formatted with a copy of the runtime operating system and all
firmware will have been flashed.

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
This process runs some acceptance tests on sphere's that have been produced by the '03-SDCARD' process. In particular, it collects
various hardware and software identifiers from the device and runs a collection of automated and semi-automated test cases. During
the semi-automated tests, the operator is expected to perform an action (tap - in test 0010) or confirm the integrity of the led matrix display or underlight (tests 0030 -> 0050) and then either confirm or reject the test with the left (confirm) or right (reject) mouse button.

Setup Steps
-----------

1. Unpack the zip files in the 04-TEST directory into directory on a Windows machine (e.g. c:\NinjaFactory\04-TEST)

Steps Per Shift
---------------
2. For each operator and com port:

    a. run the test_run.bat file

    b. enter the COM port to be used for this instance (e.g. COM10, COM11 or whatever)

    c. scan the operator id

Steps Per Sphere
----------------
3. For each sphere scanned by each operator.

    a. scan the serial id of the first sphere

    b. Connect the mini-USB and USB mouse cable to the sphere under test

    c. Connect the power cable to the sphere under test

    d. Wait for the 0010 (tap) symbol to appear

    e. Perform tests 0010, 0030, 0040 and 0050.

4. When the operator goes off shift, they should enter QUIT for the next serial number.

    This will cause the program to exit and allow the next operator to enter the COM port of each TTY
    device and the operator ID.

REVISION HISTORY
----------------
* 1.0.17a
      Updated ninjasphere-factory-test (1.0.19) with improved support for detecting faulty antennas (test 0010)

* 1.0.17

      New version of NAND - 1fc302821e7ca96a15cf8a851529211cfc9781ea

      This version causes NAND boots to initiate factory reset unless explicitly disabled by a variable, RECOVERY_DISABLE_UNFORCED_RESET=true
      set in either/var/volatile/run/media/mmcblk0p4/recovery.env.sh or factory.env.sh on a USB thumb drive.

* 1.0.16

      New version of NAND - 23c5f11d40915f43233fa5ba2106016e827062f6
      Make sure sdcard recovery script considers itself (unpacked into /tmp) when choosing the latest script to execute.
      fix: on_sdcard implementation must return true when running on the sphere.
      workaround for change in 3.12 WLAN behaviour.
      Avoid unpacking over an existing unpack (we might delete ourselves!)
      fix: text of message 0607.
      Try 3 times to bring the wlan0 interface up.
      Add some delays in attempt to workaround the unreliability of these calls.
      Bring wlan0 down before bringing the supplicant down.
      Only execute 'with large-tmp' on the NAND, otherwise we hide a script we are trying to execute.
      fix: don't forget to execute the thing!

* 1.0.15

    	New version of NAND - 08aeb8ae687cd6a119950f35199536702e276fd3
      Add support for recovery.sh make-recovery-usb /Volumes/USB sphere-testing.
      fix: make image download more reliable.
      Purge the image root directory of all existing media.
      Remove duplicate message.
      Improve formatting of fetch log messages.
      with_rw: don't exit, just return - let caller deal with it as required.
      This is required to ensure we use the write parameters when copying the remainder of the media.
      Pause briefly to display the reason for exit.
      If we have a USB drive, log to it. Copy existing log to USB first.
      Respect recovery.env.sh during factory resets.
      Force subsequent SDCARD resets from this image too.
      Add on_sphere guard
      Trace all rm calls.
      Make (require media-updated) directly responsible for making room, as required.
      Remove responsibility for cleaning up p4 from factory.env.sh
      Move resposibility for updating recovery.env.sh on p4 into post_reset_hook.

* 1.0.13

	New version of ninjasphere-factory-test (1.0.18).
	Add a memory test (0006).
	Fix /etc/init/sphere-usb-packages.conf so that packages listed in usb-packages.manifest are installed during boot.
	Capture NAND SHA1 and kernel version string during test.
	Updated NAND (4a24ca739fdde433b259fbc7978115d29505b50b).
	NAND update fixes problem since v1.0.9 where files were not copied from USB.

* 1.0.12

	Capture nand.sha1 in /etc/firmware-versions of NAND and SDCARD.
	Avoid reflashing ledmatrix firmware during SDCARD boot, if done during NAND boot.

* 1.0.11

	Refinements to process to use an SDCARD image which can flash the NAND from the factory jig.

* 1.0.2, et al

	Initial release.
