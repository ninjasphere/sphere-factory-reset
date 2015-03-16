Ninja Sphere USB Packages ({SHA1})
====================================

A copy of this [package](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{SHA1}.zip) [(sha1)](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{SHA1}.zip.sha1) can be downloaded from the Ninja Sphere firmware site.

Why this fix is necessary?
==========================
The WiFi chip used by the Ninja Sphere does not officially support 5GHz WiFi networks and so the device does not have a 5GHz antenna. However, without configuration that this package provides, the chipset will still try to connect to any 5GHz network that it happens to detect. If this happens, lack of the 5GHz antenna means that connections to an unsupported 5GHz network will be of degraded quality as compared to connections to a supported 2.4GHz network.

More information about the underlying problem can be found in [Theo Julienne's post](https://discuss.ninjablocks.com/t/pairing-problems-progess-and-a-survey-update/3099/13?u=jon_seymour) to the Ninja Sphere discussion pages.

Do I need to install this fix?
==============================
It might be advisable to install this fix if you are having trouble setting up your Ninja Sphere particularly if the network discovery or software update phases seem particularly slow or unreliable. Ninja Spheres that have already been paired should automatically receive this fix themselves, but if you are not sure whether you have the fix, there is no harm installing it using the procedure below. Note that this package does not fix every problem with the pairing process - Ninja Sphere owners should also ensure that their phone is running the latest version of the phone app for your platform.

What does this fix do?
======================
This zip file contains a patch for WiFi network configuration used by the Ninja Sphere hardware. In particular, it forces the Ninja Sphere to only connect to 2.4GHz networks.

The fix also installs a support agent that allows Ninja Blocks support staff to collect configuration information from your Ninja Sphere once it has connected to a network. If you would prefer not to install the support agent, feel free to edit usb-packages.manifest to remove the reference to ninja-scriptrock .deb file and do not copy that file onto the USB key.

What files are in the fix?
==========================

The zip archive contains 3 files:

	# This file.
	README-{SHA1}.md

	# The Sphere Wireless configuration changes to disable scans of 5GHz networks
	sphere-wireless-conf_0.2~trustyspheramid-4_armhf.deb

	# The Ninja Blocks support agent
	ninja-scriptrock_0.1~trustyspheramid-23_armhf.deb

	# A manifest containing the sha1 sums of the other files.
	usb-packages.manifest


How do I install the fix?
=========================

To install the fix onto a Ninja Sphere, do the following:

1. copy the usb-packages.manifest and .deb package files onto the root partition of a clean USB key
2. remove all cables from the Ninja Sphere (power and mini-USB cable)
3. insert the USB key into USB socket in the base of the sphere.
4. insert the power cord into the Ninja Sphere.
5. let the Ninja Sphere boot as it normally would, then complete the pairing process

The software will automatically install as part of the normal boot process of the Ninja Sphere. Note: if the Ninja Sphere boots and displays a sequence of 4 digit LED status codes, you must first let the factory reset process complete before attempting the above procedure.

If you encounter problems while installing this fix, please email [support@ninjablocks.com](mailto:support@ninjablocks.com) or visit [The Ninja Sphere Support](https://discuss.ninjablocks.com/category/ninja-sphere/support) discussion pages.