#Resetting a devkit
These instructions document how to reset a Ninja Sphere devkit with the latest devkit factory image.

#Steps

1. Download the [Ninja Sphere devkit factory image](https://firmware.sphere.ninja/latest/ubuntu_armhf_trusty_norelease_devkit-stable.img.gz). The expected sha1 of the file is listed in the [manifest](https://firmware.sphere.ninja/latest/ubuntu_armhf_trusty_norelease_devkit-stable.manifest).
2. Using the image, re-image a micro SD CARD that has at least 3GB of capacity using the steps in /howtos/burning\_an\_image
3. Remove the power cable from the devkit
4. Install the micro SD card into the micro SD card reader on the devkit
5. Reconnect the power cable to the devkit

At this point the devkit should boot with an adhoc wirless network called NinjaSphere-xxxxxxxx where xxxxxxxx is a pseudo-random string of hexadecimal digits.

6. Start the Ninja Sphere phone app and ensure that the phone app is signed in with a valid Ninja Blocks account
7. In the phone app, click "Add things" and select "Spheramid" from the list of options to advance to the "WELCOME - Tap the sphere below to begin setup" screen
8. Tap the sphere in the center of the screen to advance to the "SPHERAMID - We're looking for your spheramid" screen
9. Tap the sphere in the center of the screen 8 times until the "ADHOC PAIRING" button appears at the bottom of the screen.
10. Select the "ADHOC PAIRING" button to advance to the next screen. Follow the instructions displayed on that screen.
11. Resume the phone application and select "Continue" from the "SPHERAMID SETUP" screen

The devkit will eventually prompt for the WiFi credentials of your main WiFi network. Once these credentials are entered, the devkit will download necessary updates from the Internet. This process may take up to 15 minutes at which point the devkit will be paired with your Ninja Blocks account.

If the devkit is the only 'sphere' connected to the your Ninja Block account (e.g. it is effectively the "master" 'sphere'), the devkit LED will turn green once pairing is complete. Otherwise, it will turn blue.

##Restarting the pairing process

If the devkit fails to pair for some reason, or if the devkit loses connectivity to the Internet, then the devkit LED will continue to flash red. If the pairing process does not complete successfully or you want to re-pair the devkit to a different Ninja Blocks account, then logon to the devkit across a serial connection to its mini-USB port using a PC terminal console program like PuTTY (Windows) or screen (Linux and OSX).

Once you have logged in to the ninja account, type the following command:

	sudo with-rw /opt/ninjablocks/bin/sphere-reset --reset-setup &&	sudo reboot

This command will reset your devkit into an unpaired state, allowing you to repeat the pairing process again.
