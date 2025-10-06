#!/bin/zsh

# Install required packages
sudo apt update
sudo apt install -y dkms build-essential
sudo apt install zstd mokutil kmod
# Clone bluetooth-6.14 repo into parent directory
cd ..
if [ ! -d "bluetooth-6.14" ]; then
	git clone https://github.com/k-sae/bluetooth-6.14.git
fi


# Install mokutil and openssl
sudo apt install -y mokutil openssl

# Go to utilz directory
cd ../utilz

# Create directory for MOK keys
sudo mkdir -p /root/mok-keys

# Generate MOK keys
sudo openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv \
	-outform DER -out MOK.der -nodes -days 3650 \
	-subj "/CN=My Secure Boot DKMS key/"

# Secure and copy keys
sudo chmod 600 MOK.priv
sudo cp MOK.priv /root/mok-keys
sudo cp MOK.der /root/mok-keys

# Clean up local key files
rm MOK.priv
rm MOK.der

// this may not work in a non-interactive shell
// so call it at the end of the script
# sudo mokutil --import /root/mok-keys/MOK.der



cd bluetooth-6.14

# Add, build, and install DKMS module
sudo dkms add .
sudo dkms build btusb/4.3
sudo dkms install btusb/4.3

sudo zstd -d /lib/modules/$(uname -r)/updates/dkms/btusb.ko.zst



chmod +x sign-btusb.sh

sudo ./sign-btusb.sh
sudo cp sign-btusb.sh /usr/local/bin/sign-btusb.sh

sudo chmod +x /usr/local/bin/sign-btusb.sh
# add post build hook to dkms.conf
echo 'POST_BUILD="sign-btusb.sh"' | sudo tee -a /usr/src/btusb-4.3/dkms.conf