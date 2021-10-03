# /usr/share/X11/xkb/symbols/ara <- arabic layout location
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<alt>Shift_R']"


echo "installing nemo...."
sudo apt-get -y install nemo

echo "installing vlc...."
sudo apt-get -y install vlc

echo "installing Git...."
sudo apt-get -y install git

echo "installing JDK...."
sudo apt -y install openjdk-8-jdk
sudo apt -y install openjfx

echo "installing grub-customizer...."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt-get update
sudo apt-get -y install grub-customizer

echo "installing tweak tools"
sudo apt install gnome-tweak-tool -y

echo "installing themes...."
sudo apt-add-repository ppa:tista/adapta -y  
sudo apt update  
sudo apt -y install adapta-gtk-theme  


# natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# no desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false

echo "installing thumpnailers...."
sudo apt-get -y install ffmpegthumbnailer
sudo apt-get -y install ffmpegthumbs
sudo apt install gstreamer1.0-libavQ

echo "-----------------------------------------"
echo "Hello u there ^^"
echo "would u like to install and add config for i3wm ? (y)"
read input

if [ $input = "y" ]; then
	echo "configing i3"

	# install ranger
	sudo apt install ranger -y
        # cd to the current direcory for ranger
	echo 'alias ranger='"'"'ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'"'"'' >> $HOME/.bashrc 
	
	# for theming 	
	sudo apt install lxappearance gtk-chtheme qt4-qtconfig -y
	
	# for unlocking gnome keyring (Experimental)
	# cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
	# echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)' >> $HOME/.xinitrc
	# echo 'export SSH_AUTH_SOCK' >> $HOME/.xinitrc
	
	# for contrling synaptic touch-pad
	sudo apt-get -y install synaptic

	sudo apt -y install pavucontrol
	# well, installing the actual i3 at last
	sudo apt install i3 -y
	
	# alternative to dmenu for desktop items
	sudo apt install rofi

	# so i3 can call the pkexec command
	echo "installing gnome policy kit"
	sudo apt-get -y install policykit-1-gnome
	
	# adding custom config for i3
	mkdir $HOME/.config/i3 -p
	cp i3wm/config $HOME/.config/i3/config
	
	# for a custom satus bar
	# mkdir $HOME/.config/i3status -p
	# cp i3wm/i3status/config $HOME/.config/i3status/config
else
	echo "aborting..."
fi

# override gnome large title bar padding
mkdir $HOME/.config/gtk-3.0/
cp themes/gtk.css $HOME/.config/gtk-3.0/gtk.css

echo "removing default ubuntu sidebar"
sudo mv /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com ~/


echo "adding setAswallpaper script"
echo "WARNING: this feature is intended for ubuntu 18.10"
echo "would u like to continue? (y)"
read input
if [ $input = "y" ]; then
	cp extensions/ubuntu_gnome/SetAsWallpaper $HOME/.local/share/nautilus/scripts/
	sudo chmod +x $HOME/.local/share/nautilus/scripts/SetAsWallpaper
	sudo cp themes/ubuntu.css /etc/alternatives/gdm3.css
else
	echo "aborted..."
fi


# echo "adding Right shift toggle to bindings"
# sudo echo "  grp:rctrl_rshift_toggle Right Ctrl+Right Shift" >> /usr/share/X11/xkb/rules/evdev.lst 

x-www-browser https://www.gnome-look.org/ 

echo 'finished ^^'
echo 'Bonus note: user "nohup" for redirecting output"
