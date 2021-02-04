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
mount -t vfat "${DISK}1" /mnt/boot/
mkdir /mnt/Home
mount -t ext4 "${Disk}2" /mnt/Home/
mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
#--------------------------------------------------------------------------------

echo "--------------------------------------"
echo "---Arch Install on Main Drive---------"
echo "--------------------------------------"
pacstrap -i /mnt base --noconfirm --needed
arch-chroot /mnt
#----------------------------------------------------------------------------------
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
# ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
timedatectl --no-ask-password set-timezone Asia/Kolkata
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="" LC_TIME="en_US.UTF-8"
#-------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------"
echo "--          linux package           --"
echo "--------------------------------------"
pacman -S linux linux-headers linux-lts linux-lts-headers

echo "--------------------------------------"
echo "--  text editor,othet packages      --"
echo "--------------------------------------"
pacman -S vim openssh base-devel nano sudo dialog --noconfirm --needed
systemctl enable sshd

echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager wpa_supplicant wireless_tools netctl --noconfirm --needed
systemctl enable NetworkManager

#---------------------------------------------------------------------------------------------------------------------------
mkinitcpio -p linux
mkinitcpio -p linux-lts
#--------------------------------------------------------------------------------------------------------------------------------
# Set keymaps
localectl --no-ask-password set-keymap us

# Hostname
hostnamectl --no-ask-password set-hostname ${hostname}
#-------------------------------------------------------------------------------------
echo "--------------------------------------"
echo "--      Set Password for Root       --"
echo "--------------------------------------"
echo "Enter password for root user: "
passwd << EOF_rpasswd
${password}
${password}
EOF_rpasswd

useradd -m -g users -G wheel ${username}
passwd ${username} << EOF_upasswd
${password}
${password}
EOF_upasswd

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %sudo ALL=(ALL) ALL/%sudo ALL=(ALL) ALL/' /etc/sudoers
#---------------------------------------------------------------------------------------------
echo "--------------------------------------"
echo "-- Bootloader Systemd Installation  --"
echo "--------------------------------------"
pacman -S grub efibootmgr dosfstools os-prober --noconfirm --needed
grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg
#-------------------------------------------------------------------------------------------------
echo "--------------------------------------"
echo "--               GUI                --"
echo "--------------------------------------"
pacman -S xorg-Server xf86-video-intel libgl mesa nvidia-lts nvidia-libgl xorg-xinit xorg-xrandr xorg-xsetroot firefox nitrogen picom --noconfirm --needed
cp /etc/X11/xinit/xinitrc .xinitrc
pacman -S wget intel-ucode --noconfirm --needed


#-----------------------------------------------------
exit
umount -a 

echo "--------------------------------------"
echo "--   SYSTEM READY FOR FIRST BOOT    --"
echo "--------------------------------------"

