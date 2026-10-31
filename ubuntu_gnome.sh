#!/bin/bash
# Fresh Ubuntu (GNOME) setup: apps, dev tools, zsh and GNOME preferences.
# Run as your normal user (NOT with sudo) from anywhere: ./ubuntu_gnome.sh
# Safe to re-run: every step skips what is already installed.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
. /etc/os-release   # UBUNTU_CODENAME

if [ "$EUID" -eq 0 ]; then
	echo "run this as your user, not root (it asks for sudo itself)"
	exit 1
fi

step() { echo; echo "==> $*"; }

# ask for the password once and keep sudo alive for the whole run
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

#######################################
# apt repositories
#######################################
step "base tools for adding repositories..."
sudo apt-get update
sudo apt-get -y install ca-certificates curl wget gpg software-properties-common

step "adding grub-customizer ppa..."
sudo add-apt-repository -y -n ppa:danielrichter2007/grub-customizer

step "adding vscode repo..."
sudo install -d -m 0755 /usr/share/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
# we manage the repo file ourselves, don't let the package add a duplicate
echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections

step "adding docker repo..."
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

#######################################
# apt packages
#######################################
step "installing apt packages..."
sudo apt-get update
sudo apt-get -y install \
	git jq unzip vlc \
	chntpw `# bluetooth pairing keys shared with windows` \
	grub-customizer \
	gnome-tweaks gnome-shell-extension-manager gnome-browser-connector \
	flameshot imagemagick \
	ffmpegthumbnailer gstreamer1.0-libav `# thumbnails + codecs` \
	flatpak gnome-software-plugin-flatpak \
	zsh \
	build-essential gh python3-pip python3-venv \
	code \
	docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

step "adding flathub..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

step "installing brave..."
command -v brave-browser >/dev/null || curl -fsS https://dl.brave.com/install.sh | sh

step "docker without sudo (takes effect after re-login)..."
sudo usermod -aG docker "$USER"

#######################################
# user level dev tools
#######################################
step "installing nvm + node lts..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
	NVM_VERSION=$(curl -fsS https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r .tag_name || echo v0.40.3)
	# PROFILE=/dev/null: our zshrc loads nvm, don't let the installer edit rc files
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE=/dev/null bash
fi
set +u   # nvm.sh is not nounset-safe
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
set -u

step "installing miniconda..."
if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
	installer=$(mktemp --suffix=.sh)
	curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh" -o "$installer"
	bash "$installer" -b -p "$HOME/miniconda3"
	rm -f "$installer"
fi

#######################################
# zsh
#######################################
step "installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
	git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

step "installing zshrc..."
if [ -f "$HOME/.zshrc" ] && ! cmp -s "$REPO_DIR/zshrc/ubuntu.zshrc" "$HOME/.zshrc"; then
	cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
fi
cp "$REPO_DIR/zshrc/ubuntu.zshrc" "$HOME/.zshrc"

step "making zsh the default shell (takes effect after re-login)..."
sudo chsh -s "$(command -v zsh)" "$USER"

#######################################
# gnome
#######################################
step "keyboard layouts (en + ar, switch with Alt+Right Shift)..."
# old arabic layout: the new upstream one makes Right Alt a level3 key,
# which breaks the Alt+Right Shift switch while typing arabic.
# ~/.config/xkb overrides /usr/share/X11/xkb on wayland and survives updates
mkdir -p "$HOME/.config/xkb/symbols"
cp "$REPO_DIR/ara" "$HOME/.config/xkb/symbols/ara"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ara')]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_R']"

step "workspaces..."
# fixed 6 workspaces so Super+1..6 always has a target
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
for i in 1 2 3 4 5 6; do
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
# free Super+N from the dash / dock app launchers
for i in 1 2 3 4 5 6 7 8 9; do
	gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

step "windows..."
gsettings set org.gnome.desktop.wm.keybindings close "['<Super><Shift>q']"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Shift><Super>d']"

step "desktop, dock, touchpad..."
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.shell.extensions.ding show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
# disabled rather than deleted, re-enable with: gnome-extensions enable ubuntu-dock@ubuntu.com
gnome-extensions disable ubuntu-dock@ubuntu.com || true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

step "gnome extensions (load after re-login)..."
# builds from extensions.gnome.org matching this gnome-shell; color-picker is installed but left off
GNOME_VER="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
EXTENSIONS="blur-my-shell@aunetx caffeine@patapon.info color-picker@tuberry dash-to-dock@micxgx.gmail.com
	hidetopbar@mathieu.bidon.ca rounded-window-corners@fxgn user-theme@gnome-shell-extensions.gcampax.github.com"
EXT_TMP="$(mktemp -d)"
for uuid in $EXTENSIONS; do
	if [ -d "$HOME/.local/share/gnome-shell/extensions/$uuid" ]; then continue; fi
	url="$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$GNOME_VER" | jq -r '.download_url // empty')" || url=""
	if [ -z "$url" ]; then echo "no gnome $GNOME_VER build of $uuid, skipped"; continue; fi
	curl -fsSL -o "$EXT_TMP/$uuid.zip" "https://extensions.gnome.org$url"
	gnome-extensions install --force "$EXT_TMP/$uuid.zip"
done
rm -rf "$EXT_TMP"
# gsettings instead of `gnome-extensions enable`: the running shell can't see new extensions until re-login
for uuid in $EXTENSIONS; do
	if [ "$uuid" = color-picker@tuberry ]; then continue; fi
	enabled="$(gsettings get org.gnome.shell enabled-extensions)"
	case "$enabled" in *"'$uuid'"*) continue ;; esac
	if [ "$enabled" = "@as []" ]; then enabled="['$uuid']"; else enabled="${enabled%]}, '$uuid']"; fi
	gsettings set org.gnome.shell enabled-extensions "$enabled"
done

step "nautilus 'SetAsWallpaper' script..."
mkdir -p "$HOME/.local/share/nautilus/scripts"
cp "$REPO_DIR/extensions/ubuntu_gnome/SetAsWallpaper" "$HOME/.local/share/nautilus/scripts/"
chmod +x "$HOME/.local/share/nautilus/scripts/SetAsWallpaper"

echo
echo 'finished ^^  log out and back in for zsh, docker group, keyboard layout and gnome extensions to apply'
