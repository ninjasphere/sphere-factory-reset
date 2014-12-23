RELEASE NOTES
=============

1.0.9.803 - [8031f9f703f92daf410be9e0c8ee3732cc0de493](https://firmware.sphere.ninja/latest/nand-8031f9f703f92daf410be9e0c8ee3732cc0de493.tgz) - 2014/12/23
	* Flash led matrix in NAND boot before recovery starts [ version flashed in /etc/firmware-versions/ledmatrix.md5 ]

1.0.8.9f9 - [9f951fcc3569013919e21dc9bb9934f9183cdd1b](https://firmware.sphere.ninja/latest/nand-9f951fcc3569013919e21dc9bb9934f9183cdd1b.tgz) - 2014/12/22
	* Disable led matrix until we have a chance to flash it.

1.0.7.c46 - [c4699f2a0a3dac75d1f4f2c8b529ef113af72ed4](https://firmware.sphere.ninja/latest/nand-c4699f2a0a3dac75d1f4f2c8b529ef113af72ed4.tgz) - 2014/12/22
	* Updated kernel to support underlights
	* Flash led matrix initialized during factory reset

	See:
		http://firmware.sphere.ninja/latest/factory-reset-for-3.12-spheres-v1.0-8dabf539.zip - USB image
		https://gist.github.com/jonseymour/e6bbc4862a7527e5c45c - for process instructions


1.0.6.f9e - [f9e0efb031bfb1e39cf20487e88168f604d3e671](https://firmware.sphere.ninja/latest/nand-f9e0efb031bfb1e39cf20487e88168f604d3e671.tgz) - 2014/12/21
	* On an SDCARD boot, if a USB disk is present and factory.env.sh exists, a factory reset will be forced.
	* At the end of factory reset, a function called post_reset_hook will be called.

	This function has been configured to inject a new version of ninjapshere-factory-test which has these features:

	* On first SDCARD boot following flash, spinner does not start spinning until all firmware flashed.
	* On all SDCARD boots, if any firmware changes, the system calls /usr/local/bin/firmware-changed-hook if it is executeable.
	* The current implementation of /usr/local/bin/firmware-changed-hook reboots the system.

	A consequence of these changes is that the first stable SD card boot (the 2nd actual SD card boot) will have a phone icon, rather than a spinner.

	NOTE: the zip containing the USB recovery images for the changes has changed.

	See:
		http://firmware.sphere.ninja/latest/factory-reset-for-3.2-spheres-v1.1-d6f669ca.zip - for the updated USB image
		https://gist.github.com/jonseymour/c12855c41a9d96ffe146 - for a revised 3.2 flashing process.


1.0.5.f64 - [f642fec25dc88a8164f97d3632a5ffd341aa0e48](https://firmware.sphere.ninja/latest/nand-f642fec25dc88a8164f97d3632a5ffd341aa0e48.tgz) - 2014/12/20
	* Allows factory reset using recovery media read from a USB thumb drive connected to the Sphere's USB port
	* Allows special casing of 3.2 migrations using a factory.env.sh file stored on the USB thumb drive

1.0.4.218 - [2185973c9e33fd24f4819ecb5aac1a599cc29094](https://firmware.sphere.ninja/latest/nand-2185973c9e33fd24f4819ecb5aac1a599cc29094.tgz) - 2014/12/18
	* Reverted early patching of eth2 in 1.0.4.df5 since this seemed to cause a kernel panic

1.0.4.df5 - [df53059d53807f63ed39581d25c83719a809340e](https://firmware.sphere.ninja/latest/nand-df53059d53807f63ed39581d25c83719a809340e.tgz) - 2014/12/18
	* Points at https://firmware.ninja.sphere/latest.
    * Is slightly gentler to udev during initialization to allow time for serial gadget to connect.

1.0.4.ac1 - [ac165667652bac90be03e6dc6e32b0d7a0b1cd73](https://firmware.sphere.ninja/latest/nand-ac165667652bac90be03e6dc6e32b0d7a0b1cd73.tgz) - 2014/12/18

1.0.3 - [59adcff69fdcea27a747009e141494cb5206bca2](https://firmware.sphere.ninja/latest/nand-59adcff69fdcea27a747009e141494cb5206bca2.tgz) - 2014/12/17

	This version ensures that a recovery script only delegates to recovery scripts that are younger than itself. This allows the
	and old version on the NAND to delegate to a younger version downloaded from the network but ensures that it won't accidentally
	delegate to older versions that may contain bugs.

	Also unpacts are done with in a chroot'd environment so that writes to /tmp actually occur on a large device.

0.1.0 - [fcbaab80fd7119725aab7da0c12069f29d5c9691](https://firmware.sphere.ninja/latest/nand-fcbaab80fd7119725aab7da0c12069f29d5c9691.tgz) - 2014/12/16.


	This version fixes repartitioning issues and a race condition with udev.