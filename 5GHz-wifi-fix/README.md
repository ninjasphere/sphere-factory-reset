Ninja Sphere USB Packages ({SHA1})
====================================

A copy of this [package](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{SHA1}.zip) [(sha1)](https://firmware.sphere.ninja/latest/ubuntu%5Farmhf%5Ftrusty%5Fnorelease%5Fsphere-stable-usb-packages-{SHA1}.zip.sha1) can be downloaded from the Ninja Sphere firmware site.

Why this fix is necessary?
==========================
The WiFi chip used by the Ninja Sphere does not officially support 5GHz WiFi networks and so the device does not have a 5GHz antenna. However, without configuration that this package provides, the chipset will still try to connect to any 5GHz network that it happens to detect. If this happens, lack of the 5GHz antenna means that connections to an unsupported 5GHz network will be of degraded quality as compared to connections to a supported 2.4GHz network.

More information about the underlying problem can be found in [Theo Julienne's post](https://discuss.ninjablocks.com/t/pairing-problems-progess-and-a-survey-update/3099/13?u=jon_seymour) to the Ninja Sphere discussion pages.

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

	# A factory test suite which also includes a component required to update the other packages.
	ninjasphere-factory-test_1.0.22.deb

	# A manifest containing the sha1 sums of the other files.
	usb-packages.manifest

Should I install this fix?
==============================
It might be advisable to install this fix if you know you have a Dual Band WiFi router or if you are having trouble setting up your Ninja Sphere particularly if the network discovery or software update phases seem particularly slow or unreliable. Ninja Spheres that have already been paired should automatically receive this fix themselves, but if you are not sure whether you have the fix, there is no harm installing it using the procedure below. Note that this package does not fix every problem with the pairing process - Ninja Sphere owners should also ensure that their phone is running the latest version of the phone app for your platform.

Note that if you have already configured your rooms and things and do not want to lose this configuration you might be better to wait until the fix is delivered via the normal update process. The reason is that these manual instructions require you to perform a "yellow reset" and this will necessarily purge your existing configuration. If you want the fix now, but don't want to lose any existing rooms and things
configuration, then you can proceed but make sure you skip steps 1, 6, 8 and 9. If you do any of these steps, then you MUST do step 7.

How do I install the fix?
=========================
Note that once you have started this process, if you need to abort the process for any reason, you MUST do the green reset at step 7 or else you may need to perform a full factory reset at some later time.

To install the fix onto a Ninja Sphere, do the following:

* (1) check tht you really want to do this step (see notes above) and then perform a "yellow reset" of the Ninja Sphere to get it back to a known starting point. To do this, with the LED matrix facing up, depress the reset button on tbe base of the Ninja Sphere util the LED matrix flashes yellow, then release the button. Confirm that the Ninja Sphere reboots and displays a phone icon. If not, seek help from support@ninjablocks.com.
* (2) copy the usb-packages.manifest and .deb package files onto the root partition of a clean USB key
* (3) remove all cables from the Ninja Sphere (power and mini-USB cable)
* (4) insert the USB key into USB socket in the base of the sphere.
* (5) insert the power cord into the Ninja Sphere.

If you skipped step 1, perform step 7 (a "green reset") and then stop. Otherwise:

* (6) wait for the Ninja Sphere to display the fading phone icon.
* (7) perform a "green reset" of the Ninja Sphere to reboot the Ninja Sphere.
* (8) wait for the Ninja Sphere to display the fading phone icon.
* (9) restart the phone app and start the pairing process again.

The software will automatically install as part of the normal boot process of the Ninja Sphere at step 5 and 6. The "green reset" at step 7 is required to ensure the updates are properly persisted to the sdcard.

If during this process the Ninja Sphere boots and displays a sequence of 4 digit LED status codes, you must first let the factory reset process complete before attempting the above procedure.

If you encounter problems while installing this fix, please email [support@ninjablocks.com](mailto:support@ninjablocks.com) or visit [The Ninja Sphere Support](https://discuss.ninjablocks.com/category/ninja-sphere/support) discussion pages.