printf "\033c"
echo "installing desktop"
sleep 2
pacman -S --noconfirm xorg lxappearance noto-fonts noto-fonts-emoji \
    picom noto-fonts-cjk ttf-jetbrains-mono ttf-font-awesome feh sxiv \
    mpv zathura zathura-pdf-mupdf ffmpeg fzf man-db python-pywal unclutter \
    xclip zip unzip unrar papirus-icon-theme dosfstools ntfs-3g git sxhkd \
    pipewire pipewire-pulse vim arc-gtk-theme rsync firefox neofetch \
    libnotify dunst jq aria2 dhcpcd wpa_supplicant pamixer mpd ncmpcpp \
    xdg-user-dirs libconfig polkit kitty networkmanager emacs polkit-gnome \
    gnome-keyring euberzug ranger stow nvidia nvidia-utils nvtop bspwm polybar

systemctl enable NetworkManager.service
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
print '\033c'
echo "------------------"
echo "| Creating user! |"
echo "------------------"
echo -n "Enter your username: "
read username
useradd -m -G wheel $username
passwd $username
cd /home/$username
git clone https://gitlab.com/linux_things/wallpapers
rm .bashrc
git clone https://github.com/hegde-atri/.dotfiles
cd .dotfiles
stow kitty
stow bash
stow bspwm
stow polybar
stow rofi
stow ranger
stow zathura
stow picom
stow dunst
stow custom_scripts
stow mpv
stow mpd
stow wal
sleep 2

print '\033c'
echo "Installation finised"
