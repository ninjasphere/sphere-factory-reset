## The instructions assume NAND is flashed with fcbaab80fd7119725aab7da0c12069f29d5c9691

## ON YOUR MAC, SO YOU CAN KEEP CONNECTED ACROSS REBOOTS
export TTY=/dev/usbmodem.1411 # edit this
while true; do
    screen $TTY;
    sleep 5; # to allow interrupts
done
##

### REPEAT THIS EACH TIME NAND BOOTS ###

## FROM CHRIS @ REDFERN --
#begin paste
export MAC_IP=10.0.1.141 && # dan edit this with your IP
export MAC_PORT=8000 &&
export MAC_PROTOCOL=http &&
export SSID={your-ssid} && # edit this
export PSK={ypur-psk} &&   # edit this
/opt/ninjablocks/factory-reset/bin/recovery.sh shell
#end paste
##

## FROM S3
##
#begin paste
export MAC_IP=firmware.sphere.ninja &&
export MAC_PORT=443 &&
export MAC_PROTOCOL=https &&
export SSID={your-ssid} && # edit this
export PSK={ypur-psk} &&   # edit this
/opt/ninjablocks/factory-reset/bin/recovery.sh shell
#end paste
##

#begin paste
patch_wpa() {

    recovery.sh patch wpa "$@" &&
    while true; do
    wpa_cli reconfigure;
    ifdown wlan0;
    ifup wlan0;
    echo "sleeping for 5..."
    sleep 5
    done;
}
#end paste

##
#begin paste
export MAC_PROTOCOL=${MAC_PROTOCOL:-https} &&
export MAC_IP=${MAC_IP:-firmware.sphere.ninja} &&
export MAC_PORT=${MAC_PORT:-443} &&
stty cols 132 &&
recovery.sh set enable-script-phases false  &&
recovery.sh set enable-factory-reset-io false &&
recovery.sh set prefix ${MAC_PROTOCOL}://${MAC_IP}:${MAC_PORT}/latest &&
cat /var/volatile/run/media/mmcblk0p4/recovery.env.sh &&
/etc/init.d/ninjasphere-factory-reset.sh stop &&
/etc/init.d/ninjasphere-factory-reset.sh start &&
cat /var/volatile/run/media/mmcblk0p4/recovery.env.sh &&
ls -ltr &&
echo ok ||
(echo failed && exit 1)
#end paste
##

patch_wpa "$SSID" "$PSK" # ctrl-C when network is up during a sleep

ifup wlan0 # this is required to ensure wlan0 is up

tail -f /var/log/ninjasphere-factory-reset.log

###

# if phone icon appears on led matrix while the system is still booted to NAND
# then kill the setup assistant, verify the network is good or re-run
# the patch_wpa step.