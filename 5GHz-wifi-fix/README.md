Ninja Sphere USB Packages ({VERSION}-{SHA1})
====================================

A copy of this [package](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{VERSION}-{SHA1}.zip) [(sha1)](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{VERSION}-{SHA1}.zip.sha1) can be downloaded from the Ninja Sphere firmware site.

What does this fix do?
======================
This zip file contains a patch for WiFi network configuration used by the Ninja Sphere hardware. In particular, it forces the Ninja Sphere to only connect to 2.4GHz networks.

The fix also installs a support agent that allows Ninja Blocks support staff to collect configuration information from your Ninja Sphere once it has connected to a network. If you would prefer not to install the support agent, feel free to edit usb-packages.manifest to remove the reference to ninja-scriptrock .deb file and do not copy that file onto the USB key.

What files are in the fix?
==========================

The zip archive contains 5 files:

	# This file.
	README-{SHA1}.md

	# The Sphere Wireless configuration changes to disable scans of 5GHz networks
	sphere-wireless-conf_0.2~trustyspheramid-5_armhf.deb

	# The Ninja Blocks support agent
	ninja-scriptrock_0.1~trustyspheramid-23_armhf.deb

	# A package that helps install the other packages.
	ninja-fix-applicator_0.1.0~trustyspheramid-1_armhf.deb

	# A manifest containing the sha1 sums of the other files.
	usb-packages.manifest

Should I install this fix?
==============================
It might be advisable to install this fix if you know you have a Dual Band WiFi router or if you are having trouble setting up your Ninja Sphere particularly if the network discovery or software update phases seem particularly slow or unreliable. Ninja Spheres that have already been paired should automatically receive this fix themselves, but if you are not sure whether you have the fix, there is no harm installing it using the procedure below. Note that this package does not fix every problem with the pairing process - Ninja Sphere owners should also ensure that their phone is running the latest version of the phone app for your platform.

How do I install the fix?
=========================
Note that once you have started this process, if you need to abort the process for any reason, you MUST do the green reset at step 7 or else you may need to perform a full factory reset at some later time.

To install the fix onto a Ninja Sphere, do the following:

* (1) copy the usb-packages.manifest and .deb package files onto the root partition of a clean USB key
* (2) remove all cables from the Ninja Sphere (power and mini-USB cable)
* (3) insert the USB key into USB socket in the base of the sphere.
* (4) insert the power cord into the Ninja Sphere.

DO NOT POWER CYCLE AFTER THIS POINT UNTIL YOU SEE A RED AND WHITE STOP ICON

* (5) wait for the Ninja Sphere to display a red and white STOP icon
* (6) remove the USB key from the USB socket

DO NOT DO STEP 7 UNLESS STEP 5 COMPLETED SUCCESSFULLY.

If Step 5 did not complete successfully, then do step 6 and then a "green reset". That is, hold the reset button on the bottom of the Ninja Sphere down until the LED matrix flashes green, and then release the button.

* (7) remove and re-insert the power cable from the Ninja Sphere
* (8) wait for the Ninja Sphere to boot.

If you have not already setup the Sphere, then it might be a good idea at this point to do a "yellow reset" now and restart the setup process.

If during this process the Ninja Sphere boots and displays a sequence of 4 digit LED status codes, you must first let the factory reset process complete before attempting the above procedure.

If you encounter problems while installing this fix, please email [support@ninjablocks.com](mailto:support@ninjablocks.com) or visit [The Ninja Sphere Support](https://discuss.ninjablocks.com/category/ninja-sphere/support) discussion pages.