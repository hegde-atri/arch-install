#######################################################
# part1: make necassary partitions and chroot into it #
#######################################################
printf '\033c'
echo "----------------------------------------------"
echo "|        hegde_atri's arch installer         |"
echo "----------------------------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys uk
timedatectl set-ntp true

printf '\033c'
lsblk
echo -n "Enter drive name: "
read -r drive
cfdisk $drive
sleep 2
printf '\033c'
lsblk
echo -n "Enter EFI/boot partition: "
read -r efipartition
mkfs.vfat -F 32 $efipartition
sleep 2
printf '\033c'
lsblk
echo -n "Enter swap partition: "
read -r swappartition
sleep 2
mkswap $swappartition
sleep 2
printf '\033c'
lsblk
echo -n "Enter your root partition: "
read -r rootpartition
mkfs.ext4 $rootpartition
sleep 2
printf '\033c'
sleep 2
mount $rootpartition /mnt
mount --mkdir $efipartition /mnt/boot
swapon $swappartition

pacstrap -K /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#p2start$/d' $(basename $0) > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
echo "-----------------------------------------"
echo "| arch-chrooting into your machine now! |"
echo "-----------------------------------------"
sleep 2
arch-chroot /mnt ./archinstall2.sh
exit

#p2start
#################################
# part2: arch-chroot and config #
#################################
printf '\033c'

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf

echo -n "Enter your hostname: "
read -r hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P

echo "---------------------------"
echo "|   Enter root password   |"
echo "---------------------------"
passwd

echo "---------------------------------------"
echo "| select processor make for microcode |"
echo "|=====================================|"
echo "| For Intel, enter i                  |"
echo "| For AMD, enter a                    |"
echo "| Leave blank for both                |"
echo "---------------------------------------"
echo -n "Your processor option: "
read -r processor
if [ "$processor" == "a" ] ; then
  pacman -S --noconfirm amd-ucode
elif [ "$processor" == "i" ] ; then
  pacman -S --noconfirm intel-ucode
else
  pacman -S --noconfirm intel-ucode amd-ucode
fi
echo "---------------------------------------"
echo "|    select gpu option for drivers    |"
echo "|=====================================|"
echo "| For Nvidia, enter n                 |"
echo "| For AMD, enter a                    |"
echo "---------------------------------------"
echo -n "Your response: "
read -r gpu
if [ "$gpu" == "n" ] ; then
  pacman -S --noconfirm nvidia nvidia-utils nvtop
elif [ "$gpu" == "a" ] ; then
  pacman -S --noconfirm xf86-video-amdgpu
fi

grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=boot --removable
sed -i "s/^GRUB_GFXMODE=auto$/GRUB_GFXMODE=1920x1080/" /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o boot/grub/grub.cfg

pacman -S --noconfirm --disable-download-timeout lxappearance noto-fonts noto-fonts-emoji \
    noto-fonts-cjk ttf-jetbrains-mono ttf-font-awesome feh \
    mpv zathura zathura-pdf-mupdf ffmpeg fzf man-db \
    zip unzip unrar papirus-icon-theme dosfstools ntfs-3g git \
    pipewire pipewire-pulse vim neovim arc-gtk-theme rsync firefox neofetch \
    libnotify dunst jq aria2 dhcpcd wpa_supplicant pamixer ncmpcpp \
    xdg-user-dirs libconfig polkit kitty networkmanager emacs polkit-gnome \
    gnome-keyring ueberzug ranger obs-studio linux-headers v4l2loopback-dkms \
    exa wl-clipboard mako vlc wofi btop yt-dlp

systemctl enable NetworkManager.service

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "-----------------------"
echo "|    Creating user    |"
echo "-----------------------"
echo -n "Enter your username: "
read -r username
useradd -m -G wheel $username
passwd $username
usermod -aG video $username
echo "---------------------"
echo "finished base install"
echo "---------------------"

echo "----------------------------------------------------"
echo "|  Visit arch-wiki.hegdeatri.com for more tips :)  |"
echo "----------------------------------------------------"
