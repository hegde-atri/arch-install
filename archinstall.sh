# Deploy hegde-atri's arch config
printf '\033c'
echo "-------------------------------------"
echo "|    hegde-atri's arch installer    |"
echo "-------------------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys gb
timedatectl set-ntp true
printf '\033c'
echo -n "Enter drive name: "
read drive
cfdisk $drive
sleep 2
printf'\033c'
lsblk
echo -n "Enter EFI/boot partition: "
read efipartition
mkfs.vfat -F 32 $efipartition
sleep 2
print '\033c'
lsblk
echo -n "Enter swap partition (leave empty for no swap): "
read swappartition
echo "If you do not have a swap partition, ignore the error below"
sleep 2
mkswap $swappartition
sleep 2
print '\033c'
lsblk
echo -n "Enter your root partition: "
read rootpartition
mkfs.ext4 $rootpartition
sleep 2
print '\033c'
lsblk
echo -n "Enter your home partition (if applicable): "
read homepartition
echo "If you do not have a home partition ignore the error below"
sleep 2
mkfs.ext4 $homepartition
mount $rootpartition /mnt
mount --mkdir $homepartition /mnt/home
mount --mkdir $efipartition /mnt/boot
swapon $swappartition
sleep 2
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#p2start$/d' `basename $0` > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
echo "-----------------------------------------"
echo "| arch-chrooting into your machine now! |"
echo "-----------------------------------------"
sleep 2
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
printf '\033c'
echo -n "Enter hostname: "
read hostname
echo "$hostname" > /etc/hostname
echo -ne "
127.0.0.1       localhost
::1             localhost
127.0.1.1       '$hostname'.localdomain '$hostname'" > /etc/hosts
mkinitcpio -P
printf '\033c'
echo "Enter your root password"
passwd
printf '\033c'
pacman --noconfirm -S grub efibootmgr os-prober
printf '\033c'
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
sleep 2
git clone https://github.com/hegde-atri/arch-install
cd arch-install
printf '\033c'
echo "------------------------------"
echo "|    what are you using ?    |"
echo "|   a) desktop               |"
echo "|   b) laptop                |"
echo "------------------------------"
echo -n "Your choice: "
read choice
if [ "$choice" == "b" ] ; then
   ./laptop.sh
   exit
else
    ./desktop.sh
    exit
fi
