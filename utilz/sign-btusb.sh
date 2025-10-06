#!/bin/bash


sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha512 \
    /root/mok-keys/MOK.priv /root/mok-keys/MOK.der \
    /lib/modules/$(uname -r)/updates/dkms/btusb.ko.zst

sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha512 \
    /root/mok-keys/MOK.priv /root/mok-keys/MOK.der \
    /lib/modules/$(uname -r)/updates/dkms/btusb.ko

depmod -a
