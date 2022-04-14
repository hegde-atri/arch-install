# This script will deploy arch linux with my suckless dwm config.

#######################################################
# part1: make necassary partitions and chroot into it #
#######################################################
printf '\033c'
echo "----------------------------------------------"
echo "|        hegde_atri's arch installer         |"
echo "----------------------------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
echo "use colemak instead of qwerty? [y/n] "
read klayout
if [ "$klayout" == "y" ]; then
  loadkeys colemak
else
  loadkeys us
fi
timedatectl set-ntp true
lsblk
echo "Enter drive name (ex: /dev/sda): "
read drive
cfdisk /dev/$drive
lsblk
echo "Enter root partition (ex: /dev/sda1): "
read partition
mkfs.ext4 $partition
lsblk
echo "Enter swap partition (ex: /dev/sda1): "
read swappartition
mkswap $swappartition
lsblk
echo "Enter EFI partition (ex: /dev/sda1): "
read efipartition
mkfs.vfat -F 32 $efipartition
mount $partition /mnt
mount --mkdir /mnt/boot
swapon /dev/$swappartition
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
# getting ready to arch-chroot
cp postinstall.sh /mnt/home
sed '1,/^#p2start$/d' `basename $0` > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
echo "-----------------------------------------"
echo "| arch-chrooting into your machine now! |"
echo "-----------------------------------------"
arch-chroot /mnt ./archinstall2.sh
exit

#p2start
#################################
# part2: arch-chroot and config #
#################################
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "-------------------------------------"
echo "use colemak instead of qwerty? (y/n) : "
read klayout
if [ "$klayout" == "y" ]; then
  echo "KEYMAP=colemak" > /etc/vconsole.conf
else
  echo "KEYMAP=us" > /etc/vconsole.conf
fi
echo "Enter your hostname: "
read hostname
echo "$hostname" > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
echo "-------------------"
echo "| CHECK HOST FILE |"
echo "-------------------"
getent hosts
sleep 3
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "---------------------------------------"
echo "| select processor make for microcode |"
echo "|=====================================|"
echo "| For Intel, enter i                  |"
echo "| For AMD, enter a                    |"
echo "---------------------------------------"
echo "Your processor option: "
read $processor
if [ "$processor" == "a" ]; then
  pacman -S --noconfirm amd-ucode
elif [ "$processor" == "i" ]; then
  pacman -S --noconfirm intel-ucode
else
  pacman -S --noconfirm intel-ucode amd-ucode
fi
grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=boot --removable
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
      noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
      feh mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
      fzf man-db xwallpaper python-pywal unclutter xclip maim \
      zip unzip unrar p7zip xdotool papirus-icon-theme ran  \
      dosfstools ntfs-3g git sxhkd fish pipewire pipewire-pulse \
      vim arc-gtk-theme rsync firefox neofetch \
      xcompmgr libnotify dunst slock jq aria2 cowsay \
      dhcpcd connman wpa_supplicant pamixer mpd ncmpcpp \
      xdg-user-dirs libconfig polkit \
      bluez bluez-utils networkmanager emacs

systemctl enable NetworkManager.service
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Enter your username: "
read username
useradd -m -G wheel $username
passwd $username
pi_path=/home/$username/postinstall.sh
mv /home/postinstall.sh $pi_path
chown $username:$username $pi_path
chmod +x $pi_path
echo "--------------------------------------------------"
echo "| Reboot and run postinstall.sh in your home dir |"
echo "| Done using the following command               |"
echo "| sudo sh postinstall.sh                         |"
echo "--------------------------------------------------"

# part3: choose DE/WM - coming soon
