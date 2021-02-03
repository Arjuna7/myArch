

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
