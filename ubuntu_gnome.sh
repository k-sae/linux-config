# /usr/share/X11/xkb/symbols/ara <- arabic layout location

gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<alt>Shift_R']"
gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Shift><Super>d']"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Shift>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Shift>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Shift>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Shift>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Shift>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Shift>6']"

gsettings set org.gnome.desktop.wm.keybindings close "['<Super><Shift>q']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

echo "installing vlc...."
sudo apt-get -y install vlc

echo "installing Git...."
sudo apt-get -y install git

echo "installing grub-customizer...."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt-get update
sudo apt-get -y install grub-customizer

echo "installing tweak tools"

sudo apt install gnome-tweaks -y
# natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# no desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false

echo "installing thumpnailers...."
sudo apt-get -y install ffmpegthumbnailer
sudo apt-get -y install ffmpegthumbs
sudo apt install gstreamer1.0-libavQ

echo "installing flathub..."
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

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


sudo apt-get install chrome-gnome-shell

echo "removing default ubuntu sidebar"
sudo mv /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com ~/



# echo "adding Right shift toggle to bindings"
# sudo echo "  grp:rctrl_rshift_toggle Right Ctrl+Right Shift" >> /usr/share/X11/xkb/rules/evdev.lst 
x
x-www-browser https://www.gnome-look.org/ 

echo 'finished ^^'
echo 'Bonus note: user "nohup" for redirecting output"
