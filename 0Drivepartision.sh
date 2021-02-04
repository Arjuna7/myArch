# Arch Linux installation



lsblk
echo "Give Uefi and Root disk"
echo "Please enter disk: (example /dev/sda)"
read DISK
lsblk
echo "Give Swap and Home disk"
echo "Please enter disk: (example /dev/sdb)"
read Disk
#---------------------------------------------------------------------------------

echo "--------------------------------------------------"
echo "-----------Update the system clock----------------"
echo "--------------------------------------------------"

timedatectl set-ntp true
timedatectl status
#----------------------------------------------------------------------------------
echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "-------       Root and uefi      ----------------"
echo "-------------------------------------------------"
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:+512M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n 2:0:0     ${DISK} # partition 2 (Root), default start, remaining

# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}

# label partitions
sgdisk -c 1:"UEFISYS" ${DISK}
sgdisk -c 2:"ROOT" ${DISK}

echo "-------------------------------------------------"
echo "-------     Home and swap        ----------------"
echo "-------------------------------------------------"

echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

#using fdisk
sudo fdisk ${Disk} << EOF_sdb
g
n


+16G
n



t
1
19
t
2
20
w
EOF_sdb

# label partitions
sgdisk -c 1:"Swap" ${Disk}
sgdisk -c 2:"Home" ${Disk}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.vfat -F32 -n "UEFISYS" "${DISK}1"
mkfs.ext4 -L "ROOT" "${DISK}2"
mkswap -L "Swap" "${Disk}1"
swapon "${Disk}1"
mkfs.ext4 -L "Home" "${Disk}2"
#---------------------------------------------------------------------------------
# mount target
mkdir /mnt
mount -t ext4 "${DISK}2" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/EFI
mount -t vfat "${DISK}1" /mnt/boot/EFI
mkdir /mnt/Home
mount -t ext4 "${Disk}2" /mnt/Home/
mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
#--------------------------------------------------------------------------------

echo "--------------------------------------"
echo "---Arch Install on Main Drive---------"
echo "--------------------------------------"
pacstrap -i /mnt base git nano glibc --noconfirm --needed


