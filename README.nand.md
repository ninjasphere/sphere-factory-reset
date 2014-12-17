RELEASE NOTES
=============

1.0.3 - [59adcff69fdcea27a747009e141494cb5206bca2](https://firmware.sphere.ninja/latest/nand-59adcff69fdcea27a747009e141494cb5206bca2.tgz) - 2014/12/17

	This version ensures that a recovery script only delegates to recovery scripts that are younger than itself. This allows the
	and old version on the NAND to delegate to a younger version downloaded from the network but ensures that it won't accidentally
	delegate to older versions that may contain bugs.

	Also unpacts are done with in a chroot'd environment so that writes to /tmp actually occur on a large device.

0.1.0 - [fcbaab80fd7119725aab7da0c12069f29d5c9691](https://firmware.sphere.ninja/latest/nand-fcbaab80fd7119725aab7da0c12069f29d5c9691.tgz) - 2014/12/16.


	This version fixes repartitioning issues and a race condition with udev.