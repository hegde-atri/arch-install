# part1: make necassary partitions and chroot into it
# 1m free space, 100M efi, 16GB swap, rest swap
printf '\033c'
echo "---------------------------"
echo "hegde_atri's arch installer"
echo "---------------------------"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
echo "use colemak instead of qwerty? [y/n] "
read klayout
if [[ $klayout = y]] ; then
  loadkeys colemak
else
  loadkeys us
fi
timedatectl set-ntp true
lsblk
echo "Enter drive name: "
read drive
cfdisk /dev/$drive
echo "Enter root partition: "
read partition
mkfs.ext4 $partition
echo "Enter swap partition: "
read swappartition
mkswap $swappartition
echo "Enter EFI partition: "
read efipartition
mkfs.vfat -F 32 $efipartition
mount $partition /mnt
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
#sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
#chmod +x /mnt/arch_install2.sh
#arch-chroot /mnt ./arch_install2.sh

# part2: configuration

# part3: choose DE/WM

# part4: apply config
