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
#---------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------
mkinitcpio -p linux
mkinitcpio -p linux-lts
#---------------------------------------

# Set keymaps
localectl --no-ask-password set-keymap us

# Hostname
hostnamectl --no-ask-password set-hostname Garuda
#--------------------------------------
#-------------------------------------------------------------------------------------
echo "--------------------------------------"
echo "--      Set Password for Root       --"
echo "--------------------------------------"
echo "Enter password for root user: "
passwd 

useradd -m -g users -G wheel lucifer
passwd lucifer

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers


systemctl enable sshd
systemctl enable NetworkManager
