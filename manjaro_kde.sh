sudo pacman -S --noconfirm yay
sudo pacman -S --noconfirm gedit
sudo pacman -S --noconfirm java-openjfx
sudo pacman -S --noconfirm grub-customizer
sudo pacman -S --noconfirm vlc
sudo pacman -S --noconfirm zsh
sudo pacman -S --noconfirm latte
sudo pacman -S --noconfirm menu-cache-git
echo 'amixer set Capture toggle && amixer get Capture | grep '"'"'\[off\]'"'"' && notify-send '"'"'MIC switched OFF'"'"' || notify-send '"'"'MIC switched ON'"'"'' | sudo tee /usr/local/bin/mic-toggle
sudo chmod +x /usr/local/bin/mic-toggle
yay -S visual-studio-code-bin


# fix the power saver popping sound
# modify the 1 to 0 in: /sys/module/snd_hda_intel/parameters/power_save
# modify the Y to N in: /sys/module/snd_hda_intel/parameters/power_save_control
# modify /etc/tlp.conf or /etc/default/tlp
#       SOUND_POWER_SAVE_ON_AC=0
#       SOUND_POWER_SAVE_ON_BAT=0
#       SOUND_POWER_SAVE_CONTROLLER=N
# https://wiki.archlinux.org/title/Power_management#Kernel
