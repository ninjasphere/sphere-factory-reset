RELEASE NOTES
=============

1.0.19.e05 - [e0530dcf1638904cd0c7135352ea1293b5f09b9a](https://firmware.sphere.ninja/latest/nand-e0530dcf1638904cd0c7135352ea1293b5f09b9a.tgz) - 2015/01/30

    * Ensure some failures always paint the devkit LEDs red.

1.0.18.b80 - [b800a427e68fc1574221221d868dd2809575a79e](https://firmware.sphere.ninja/latest/nand-b800a427e68fc1574221221d868dd2809575a79e.tgz) - 2015/01/30

    * Update injected factory reset to 1.0.17
    * fix: use Linux sed conventions, not OSX.
    * Updated with fresh stable build -  2014-12-31_0732
    * Add verifier utilities to check allow verification of the sha1 manifest.
    * Update the README.
    * Updated factory test with version 1.0.19-7.
    * Bumped test version to 1.0.21.
    * fix: pixel error.
    * Avoid an unnecessary download in the case we already have the media.
    * Update test version to 1.0.22. Add sphere-system-tweaks. Updated factory.env.sh
    * Use sha1, rather than sha1sum.
    * Re-release 01-SOM to cope with occasional NAND errors.
    * Updated README
    * Add a script that enables detection of bad block errors outside the UBI controller parts of the NAND.
 	* Updated NAND to b800a427e68fc1574221221d868dd2809575a79e

1.0.17.1fc - [1fc302821e7ca96a15cf8a851529211cfc9781ea](https://firmware.sphere.ninja/latest/nand-1fc302821e7ca96a15cf8a851529211cfc9781ea.tgz) - 2014/12/31

     * NAND boots will always reset unless explicitly disabled by RECOVERY_DISABLE_UNFORCED_RESET
     * Only do the erase if we need to do the copy.
     * Add support for a 'reboot-to-nand' command.
     * Relax requirement for ethernet check so that it can also be run on an SDCARD boot.

1.0.16.23c - [23c5f11d40915f43233fa5ba2106016e827062f6](https://firmware.sphere.ninja/latest/nand-23c5f11d40915f43233fa5ba2106016e827062f6.tgz) - 2014/12/31

This version fixes regressions with download via network support and reset initiation from SDCARD introduced in v1.0.5.

    * New version of NAND - 23c5f11d40915f43233fa5ba2106016e827062f6
    * Make sure sdcard recovery script considers itself (unpacked into /tmp) when choosing the latest script to execute.
    * fix: on_sdcard implementation must return true when running on the sphere.
    * workaround for change in 3.12 WLAN behaviour.
    * Avoid unpacking over an existing unpack (we might delete ourselves!)
    * fix: text of message 0607.
    * Try 3 times to bring the wlan0 interface up.
    * Add some delays in attempt to workaround the unreliability of these calls.
    * Bring wlan0 down before bringing the supplicant down.
    * Only execute 'with large-tmp' on the NAND, otherwise we hide a script we are trying to execute.
    * fix: don't forget to execute the thing!

1.0.15.08a [08aeb8ae687cd6a119950f35199536702e276fd3](https://firmware.sphere.ninja/latest/nand-369f64ba2979ea863a19ddb1ca134967a636e095.tgz) - 2014/12/30

    * Apply escaping rules required for generation.

1.0.15.369 [369f64ba2979ea863a19ddb1ca134967a636e095](https://firmware.sphere.ninja/latest/nand-369f64ba2979ea863a19ddb1ca134967a636e095.tgz) - 2014/12/30

	Additional fixes required to properly support factory resets of non-stable builds.

    * Respect recovery.env.sh during factory resets.
    * Force subsequent SDCARD resets from this image too.
    * Add on_sphere guard
    * Trace all rm calls.
    * Make (require media-updated) directly responsible for making room, as required.
    * Remove responsibility for cleaning up p4 from factory.env.sh
    * Move resposibility for updating recovery.env.sh on p4 into post_reset_hook.
    * Apply escaping rules required for generation

1.0.14.659 [6597aaaa6bb37ba8a3e129ad5c097faa58fd5231](https://firmware.sphere.ninja/latest/nand-6597aaaa6bb37ba8a3e129ad5c097faa58fd5231.tgz) - 2014/12/30

	* Fixes issue w.r.t. USB recovery of non-stable releases by reading factory.env.sh as soon as we find it allowing factory.env.sh control other aspects
	of recovery process, including the actual image to be loaded.

1.0.13.4a2 [4a24ca739fdde433b259fbc7978115d29505b50b](https://firmware.sphere.ninja/latest/nand-4a24ca739fdde433b259fbc7978115d29505b50b.tgz) - 2014/12/28

	* Use a generated uEnv.txt to maximise chance of detecting issues during factory flashing process.

1.0.13.2f4 - [2f4b91d0de5f75db809dc1c814a1829de5354588](https://firmware.sphere.ninja/latest/nand-2f4b91d0de5f75db809dc1c814a1829de5354588.tgz) - 2014/12/27

	* Fixes a regression introduced in 1.0.9 whereby files were not copied from USB.

1.0.12.2cb - [2cb2e8d64a01d7d14e7aae94975ea3660e660b8e](https://firmware.sphere.ninja/latest/nand-2cb2e8d64a01d7d14e7aae94975ea3660e660b8e.tgz) - 2014/12/27

	* Copy factory-flashed NAND version into /etc/firmware-versions of NAND and thence to SDCARD
	* Don't reflash ledmatrix during SDCARD boot if it was already flashed by NAND boot.

1.0.11.cac - [cac57f828d87317fd71fb2c05d6cb910b2cf099](https://firmware.sphere.ninja/latest/nand-cac57f828d87317fd71fb2c05d6cb910b2cf099.tgz) - 2014/12/27

	* rebuilt with latest sphere-setup-assistant
	* includes a copy of default configuration to support latest sphere-setup-assistant
	* divert some output to stderr

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