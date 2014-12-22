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

