grub-install --target=x86_64-efi --bootloader-id=grub-uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg



cp /etc/X11/xinit/xinitrc .xinitrc
