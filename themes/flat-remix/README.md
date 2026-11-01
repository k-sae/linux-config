Flat Remix GTK themes by Daniel Ruiz de Alegría (GPL-3.0, see LICENSE),
copied from https://github.com/daniruiz/flat-remix-gtk at commit 919494f (release 20240730).
ubuntu_gnome.sh installs them to ~/.themes and enables Flat-Remix-GTK-Red-Light.

To switch variant (e.g. Blue-Darkest):
  for f in gtk.css gtk-dark.css assets; do                                      # nautilus / gtk4 apps
    ln -sfn ~/.themes/Flat-Remix-GTK-Blue-Darkest/gtk-4.0/$f ~/.config/gtk-4.0/$f
  done
  gsettings set org.gnome.desktop.interface gtk-theme Flat-Remix-GTK-Blue-Darkest
  gsettings set org.gnome.desktop.interface accent-color blue
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark             # 'default' for light
