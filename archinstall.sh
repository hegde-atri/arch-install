# This script will deploy arch linux with options to install de/wm
#
#######################################################
# part1: make necassary partitions and chroot into it #
#######################################################
pacman -S --noconfirm figlet
printf '\033c'
figlet -k "hegde_atri's arch installer"
echo "----------------------------------------------"
echo "|        hegde_atri's arch installer         |"
echo "----------------------------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
figlet -k "choose keymap"
echo "----------------------------------------"
echo -n "use colemak instead of qwerty? [y/n] "
read klayout
if [ "$klayout" == "y" ] ; then
  loadkeys colemak
else
  loadkeys us
fi
timedatectl set-ntp true
lsblk
echo -n "Enter drive name (ex: /dev/sda): "
read drive
cfdisk $drive
sleep 2
printf '\033c'
figlet -k "root"
lsblk
echo -n "Enter root partition (ex: /dev/sda1): "
read partition
mkfs.ext4 $partition
printf '\033c'
figlet -k "home"
lsblk
echo -n "Enter home partition (ex: /dev/sda1): "
read homepartition
mount --mkdir $homepartition /mnt/home
printf '\033c'
figlet -k "swap"
lsblk
echo -n "Enter swap partition (ex: /dev/sda1): "
read swappartition
mkswap $swappartition
printf '\033c'
figlet -k "efi"
lsblk
echo -n "Enter EFI partition (ex: /dev/sda1): "
read efipartition
mkfs.vfat -F 32 $efipartition
mount $partition /mnt
mount --mkdir $efipartition /mnt/boot
swapon $swappartition
pacstrap /mnt base base-devel linux linux-firmware figlet
genfstab -U /mnt >> /mnt/etc/fstab
# getting ready to arch-chroot
cp postinstall.sh /mnt/home
sed '1,/^#p2start$/d' `basename $0` > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
figlet -k "arch-chrooting"
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
figlet -k "keymap"
echo "-------------------------------------"
echo -n "use colemak instead of qwerty? (y/n) : "
read klayout
if [ "$klayout" == "y" ] ; then
  echo "KEYMAP=colemak" > /etc/vconsole.conf
else
  echo "KEYMAP=us" > /etc/vconsole.conf
fi
figlet -k "hostname"
echo -n "Enter your hostname: "
read hostname
echo "$hostname" > /etc/hostname
echo -ne "
127.0.0.1       localhost
::1             localhost
127.0.1.1       $hostname.localdomain $hostname" > /etc/hosts
mkinitcpio -P
figlet -k "root"
figlet -k "password"
passwd
pacman --noconfirm -S grub efibootmgr os-prober
figlet -k "microcode"
echo "---------------------------------------"
echo "| select processor make for microcode |"
echo "|=====================================|"
echo "| For Intel, enter i                  |"
echo "| For AMD, enter a                    |"
echo "| Leave blank for both                |"
echo "---------------------------------------"
echo -n "Your processor option: "
read processor
if [ "$processor" == "a" ] ; then
  pacman -S --noconfirm amd-ucode
elif [ "$processor" == "i" ] ; then
  pacman -S --noconfirm intel-ucode
else
  pacman -S --noconfirm intel-ucode amd-ucode
fi
grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=boot --removable
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o boot/grub/grub.cfg
figlet -k "installing packages"

pacman -S --noconfirm xorg lxappearance\
      noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
      feh mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
      fzf man-db xwallpaper python-pywal unclutter xclip maim \
      zip unzip unrar p7zip xdotool papirus-icon-theme \
      dosfstools ntfs-3g git sxhkd fish pipewire pipewire-pulse \
      vim arc-gtk-theme rsync firefox neofetch \
      libnotify dunst jq aria2 \
      dhcpcd connman wpa_supplicant pamixer mpd ncmpcpp \
      xdg-user-dirs libconfig polkit kitty \
      bluez bluez-utils networkmanager emacs polkit-gnome gnome-keyring

echo "-------------------------------------"
echo "| Do you want nvidia drivers? (y/n) |"
echo "-------------------------------------"
echo -n "Your response: "
read nvdia
if [ "$nvidia" == "y" ] ; then
  pacman -S --noconfirm nvidia nvidia-utils nvtop
fi
systemctl enable NetworkManager.service
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
figlet -k "creating"
figlet -k "user"
echo -n "Enter your username: "
read username
useradd -m -G wheel $username
passwd $username
pi_path=/home/$username/archinstall
git clone https://github.com/hegde-atri/arch-install "$pi_path"
figlet -k "finished base install"
echo "==================================="
echo "| select your install option      |"
echo "|---------------------------------|"
echo "| (a) - bspwm + dotfiles          |"
#echo "| (b) - bspwm                     |"
#echo "| (c) - dwm                       |"
#echo "| (d) - kde                       |"
#echo "| (e) - xfce                      |"
echo "| (q) - nothing, quit             |"
echo "|---------------------------------|"
echo "| You can choose only one option  |"
echo "==================================="
echo -n "Your response: "
read wmde
if [ "$wmde" == "a" ] ; then
  sh "$pi_path"/extra/myconfig.sh full
#elif [ "$wmde" == "b" ] ; then
#  sh "$pi_path"/extra/bspwm.sh
#elif [ "$wmde" == "c" ] ; then
#  sh "$pi_path"/extra/dwm.sh
#elif [ "$wmde" == "d" ] ; then
#  sh "$pi_path"/extra/kde.sh
#elif [ "$wmde" == "e" ] ; then
#  sh "$pi_path"/extra/xfce.sh
else
  figlet -k "Thank you for using me!"
  figlet -k "star my repo !"
fi

exit
