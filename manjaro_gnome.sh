
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<alt>Shift_R']"
gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Shift><Super>d']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super><Shift>q']"

# natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# no desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false

sudo pacman -S --noconfirm nemo
sudo pacman -S --noconfirm gnome-disk-utility
sudo pacman -S --noconfirm yay
sudo pacman -S --noconfirm java-openjfx
sudo pacman -S --noconfirm grub-customizer
sudo pacman -S --noconfirm vlc
sudo pacman -S --noconfirm menu-cache-git
sudo pacman -S --noconfirm network-manager-applet

# kvm support for android emulators
sudo pacman -S --noconfirm virt-manager qemu vde2 ebtables dnsmasq bridge-utils openbsd-netcat
sudo systemctl enable libvirtd.service

# remove the pip sound
rmmod pcspkr
# doesnt work for some reason
sudo echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
echo "-----------------------------------------"
echo "Hello u there ^^"
echo "would u like to install and add config for i3wm ? (y)"
read input

if [ $input = "y" ]; then
	echo "configing i3"

	# install ranger
	sudo pacman -S --noconfirm ranger 
        # cd to the current direcory for ranger
	echo 'alias ranger='"'"'ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'"'"'' >> $HOME/.bashrc 
	
	# for theming 	
	sudo pacman -S --noconfirm gtk-chtheme
	sudo pacman -S --noconfirm qt5ct
	
	yay -S libfm-extra
	yay -S lxappearance-gtk3-git
	# for unlocking gnome keyring (Experimental)
	# cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
	# echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)' >> $HOME/.xinitrc
	# echo 'export SSH_AUTH_SOCK' >> $HOME/.xinitrc
	
	# for contrling synaptic touch-pad
	# sudo pacman -S --noconfirm synaptic


	# well, installing the actual i3 at last
	sudo pacman -S --noconfirm i3
	sudo pacman -S --noconfirm dmenu
	# alternative to dmenu for desktop items
	sudo pacman -S --noconfirm rofi
	sudo pacman -S --noconfirm pavucontrol
	sudo pacman -S --noconfirm compton
	# adding custom config for i3
	mkdir $HOME/.config/i3 -p
	cp i3wm/config $HOME/.config/i3/config
	
	# for a custom satus bar
	# mkdir $HOME/.config/i3status -p
	# cp i3wm/i3status/config $HOME/.config/i3status/config
else
	echo "aborting..."
fi

# remove the default padding
mkdir $HOME/.config/gtk-3.0/
cp themes/gtk.css $HOME/.config/gtk-3.0/gtk.css

# for notification daemon
sudo pacman -S dunst

# adding mic toggle script 
echo 'amixer set Capture toggle && amixer get Capture | grep '"'"'\[off\]'"'"' && notify-send '"'"'MIC switched OFF'"'"' || notify-send '"'"'MIC switched ON'"'"'' | sudo tee /usr/local/bin/mic-toggle
sudo chmod +x /usr/local/bin/mic-toggle


echo "adding setAswallpaper script"
echo "WARNING: this feature is intended for Gnome 30"
echo "would u like to continue? (y)"
read input
if [ $input = "y" ]; then
	cp extensions/manjaro_gnome/SetAsWallpaper $HOME/.local/share/nautilus/scripts/
	sudo chmod +x $HOME/.local/share/nautilus/scripts/SetAsWallpaper
	cp shell-theme/ $HOME/ -R
	mkdir $HOME/Pictures/Wallpapers/ -p
else
	echo "aborted..."
fi


yay -S visual-studio-code-bin
yay -S google-chrome

# fix chrome sessions issue with multiple desktops installed
# --password-store=gnome to the desktop chrome launcher

# to disable the sound beeb on battery
# echo 0 > /sys/module/snd_hda_intel/parameters/power_save

# for remapping keyboard:
#  1- https://askubuntu.com/questions/24916/how-do-i-remap-certain-keys-or-devices 
#  2- for super key: xmodmap -e "keycode 180 = Super_L"

# For Swap file
# https://askubuntu.com/questions/103242/is-it-safe-to-turn-swap-off-permanently
