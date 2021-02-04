
echo "--------------------------------------"
echo "--          linux package           --"
echo "--------------------------------------"
pacman -S linux linux-headers linux-lts linux-lts-headers

echo "--------------------------------------"
echo "--  text editor,othet packages      --"
echo "--------------------------------------"
pacman -S vim openssh base-devel nano sudo dialog --noconfirm --needed
