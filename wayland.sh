#!/bin/bash
printf '\033c'
echo "----------------------------------------------"
echo "|        hegde_atri's arch installer         |"
echo "----------------------------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring gum
loadkeys uk
timedatectl set-ntp true

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there\! Welcome to my $(gum style --foreground 212 'Arch Installer')."

printf '\033c'
lsblk
drive=$(gum input --placeholder "Choose drive")
cfdisk $drive
gum spin --spinner dot --title "Waiting for changes to persist" -- sleep 2
printf '\033c'
lsblk
efipartition=$(gum input --placeholder "EFI/Boot partition")
gum spin --spinner dot --title "Formatting EFI partition" -- mkfs.vfat -F 32 $efipartition
printf '\033c'
lsblk
swappartition=$(gum input --placeholder "Swap partition")
gum spin --spinner dot --title "Creating swap partition" -- mkswap $swappartition
printf '\033c'
lsblk
rootpartition=$(gum input --placeholder "Root partition")
gum spin --spinner dot --title "Formatting root partition" -- mkfs.ext4 -F $rootpartition
printf '\033c'
gum spin --spinner dot --title "Mounting Root partition" -- mount $rootpartition /mnt
gum spin --spinner dot --title "Mounting Boot parition" -- mount --mkdir $efipartition /mnt/boot
gum spin --spinner dot --title "Enabling swap" -- swapon $swappartition

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "The script will now $(gum style --foreground 212 'pacstrap') your system."
pacstrap -K /mnt base base-devel linux linux-firmware gum
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#p2start$/d' $(basename $0) > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "The script will now $(gum style --foreground 212 'Arch-chroot') into your system."
arch-chroot /mnt ./archinstall2.sh
exit

#p2start
printf '\033c'

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf

hostname=$(gum input --placeholder "Enter your hostname")
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
gum spin --spinner dot --title "Running mkinitcpio" -- mkinitcpio -P

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Enter your $(gum style --foreground 212 'root') password"
passwd

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Enter your $(gum style --foreground 212 'CPU') for microcode."
processor=$(gum choose "Intel" "AMD")
if [ "$processor" == "Intel" ] ; then
  pacman -S --noconfirm amd-ucode
elif [ "$processor" == "AMD" ] ; then
  pacman -S --noconfirm intel-ucode
else
  pacman -S --noconfirm intel-ucode amd-ucode
fi
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Choose what $(gum style -foreground 51 "Processor") + $(gum style --foreground 212 "GPU") setup you have." \
    "Choose $(gum style -foreground 212 "AMD") if you have AMD integrated graphics"
gpu=$(gum choose "Intel with NVIDIA" "AMD with NVIDIA" "AMD")
if [ "$gpu" == "Intel with NVIDIA" ] ; then
  pacman -S --noconfirm nvidia nvidia-utils nvtop xf86-video-intel
elif [ "$gpu" == "AMD with NVIDIA" ] ; then
  pacman -S --noconfirm xf86-video-amdgpu nvidia nvidia-utils nvtop
elif [ "$gpu" == "AMD" ] ; then
  pacman -S --noconfirm xf86-video-amdgpu
fi

grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=boot --removable
sed -i "s/^GRUB_GFXMODE=auto$/GRUB_GFXMODE=1920x1080/" /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o boot/grub/grub.cfg

pacman -S --noconfirm --disable-download-timeout lxappearance noto-fonts noto-fonts-emoji \
    noto-fonts-cjk ttf-jetbrains-mono ttf-font-awesome feh exfat-utils\
    mpv zathura zathura-pdf-mupdf ffmpeg fzf man-db \
    zip unzip unrar papirus-icon-theme dosfstools ntfs-3g git \
    pipewire pipewire-pulse vim neovim arc-gtk-theme rsync firefox neofetch \
    libnotify jq aria2 dhcpcd wpa_supplicant pamixer ncmpcpp \
    xdg-user-dirs libconfig polkit kitty networkmanager emacs polkit-gnome \
    gnome-keyring ueberzug ranger obs-studio linux-headers v4l2loopback-dkms \
    exa wl-clipboard mako vlc wofi btop yt-dlp

systemctl enable NetworkManager.service

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Enter your $(gum style --foreground 212 "username")"
username=$(gum input --placeholder "username")
useradd -m -G wheel $username
passwd $username
usermod -aG video $username
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Enter your $(gum style --foreground 212 "username")"

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Arch linux is now installed" \
    "Reboot your computer into the grub menu\!" \
    "Visit https://arch-wiki.hegdeatri.com for a helpful Arch guide"

