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

