
echo "--------------------------------------"
echo "--          linux package           --"
echo "--------------------------------------"
pacman -S linux linux-headers linux-lts linux-lts-headers --noconfirm --needed

echo "--------------------------------------"
echo "--  text editor,othet packages      --"
echo "--------------------------------------"
pacman -S vim openssh base-devel nano sudo dialog --noconfirm --needed
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager wpa_supplicant wireless_tools netctl --noconfirm --needed


pacman -S grub efibootmgr dosfstools os-prober --noconfirm --needed


pacman -S xorg-Server xf86-video-intel libgl mesa nvidia-lts nvidia-libgl xorg-xinit xorg-xrandr xorg-xsetroot firefox nitrogen picom --noconfirm --needed

pacman -S wget intel-ucode --noconfirm --needed
