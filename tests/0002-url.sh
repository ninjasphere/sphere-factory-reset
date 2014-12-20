RECOVERY_LIBRARY=true . $(dirname "$0")/../recovery.sh
testUrlSuffix()
{
	assertEquals  "url suffix" "-recovery" "$(url suffix)"
}

testUrlSuffixArg()
{
	assertEquals   "url suffix .tar" "-recovery.tar" "$(url suffix .tar)"
}

testUrlImage()
{
	assertEquals   "url image " "ubuntu_armhf_trusty_norelease_sphere-stable" "$(url image)"
}

testUrlFile()
{
	assertEquals   "url file .tar" "ubuntu_armhf_trusty_norelease_sphere-stable-recovery.tar" "$(url file .tar)"
}

testUrlPrefix()
{
	assertEquals   "url prefix" "https://firmware.sphere.ninja/latest" "$(url prefix)"
}

eval $(unit_test_script)