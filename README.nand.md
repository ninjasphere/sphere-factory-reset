RELEASE NOTES
=============

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