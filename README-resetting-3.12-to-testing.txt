5. Set up your GOPATH

	test -n "$GOPATH" || export GOPATH=~/go  &&
	( test -d "$GOPATH/src" || mkdir -p "$GOPATH/src" ) &&
	export GOPATH

10. checkout latest factory-scripts
   10a. if you don't have it:

   	#paste
   	test -n "$GOPATH" &&
   	mkdir -p ${GOPATH:-~/go}/src/github.com/ninjablocks/ &&
      	git clone git@github.com:ninjablocks/factory-scripts.git ||
      	echo failed && (exit 1)
      	#end paste

   10b. if you do have it
   	cd ${GOPATH:-~/go}/src/github.com/ninjablocks/factory-scripts &&
   	git pull --rebase origin

20. flash the current NAND (c7d420eaa8abf9dd189e44ceabac6685ab22fa9d) using the README and
	cd "${GOPATH:-~/go}/src/github.com/ninjablocks/factory-scripts" &&
	./02-dfu.sh flash c7d420eaa8abf9dd189e44ceabac6685ab22fa9d

30. with an SDCARD boot, logon to your sphere, and paste this into your terminal:

# start paste
set -x &&
mkdir -p /tmp/image &&
mount /dev/mmcblk0p4 /tmp/image &&
cd /tmp/image &&
ls -ltr &&
(
echo 'export RECOVERY_PREFIX=https://firmware.sphere.ninja/latest;'
echo 'export RECOVERY_IMAGE=ubuntu_armhf_trusty_norelease_sphere-testing;'
echo 'export RECOVERY_ENABLE_SCRIPT_PHASES=false;'
) >> recovery.env.sh &&
(rm *.tar || true) &&
ls -ltr &&
(. recovery.env.sh && set | grep ^RECOVERY) &&
echo ok ||
(echo fail && exit 1)
# end paste

40. hold down the reset button until the LED goes RED to initiate a factory reset.

50. the system will then:

  50.1 download the testing tar
  50.2 nuke the boot partition
  50.3 reboot to NAND
  50.4 reimage the devices
  50.5 reboot to SDCARD
  50.6 flash zigbee and ledmatrix on first boot (only)
  50.7 enter pairing state

