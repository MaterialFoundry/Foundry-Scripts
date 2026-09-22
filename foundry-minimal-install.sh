#!/bin/bash

divLine="----------------------------------------------------------------"

read -p "Enter the URL to your Foundry server: " url
read -p "Do you want to hide the GRUB screen on boot (y/n): " hideGrub
username="${SUDO_USER:-$USER}"
home=$(getent passwd "$username" | cut -d: -f6)
autoStartScript="$home/foundry-client-autostart.sh"
autoStartDir="$home/.config/autostart"
autoStartFile="$autoStartDir/foundry.desktop"

echo ""
echo "$divLine"
echo "Starting installation for a dedicated light-weight Foundry client"
echo "URL: $url"
echo "Username: $username"
echo "$divLine"
echo ""

echo "---- Updating system ----"
apt update
apt upgrade -y

echo ""
echo "---- Installing Chromium ----"
apt install chromium -y

echo ""
echo "---- Uninstalling Keyring ----"
sudo apt purge gnome-keyring

echo ""
echo "---- Configuring GPU acceleration ----"
apt install pciutils -y
if lspci -nn | grep -E 'VGA|3D|Display' | grep -Eiq '\[(8086|1002):'; then
    echo "-> Intel or AMD GPU found, installing mesa-utils"
    apt install mesa-utils -y
fi
if lspci -nn | grep -E 'VGA|3D|Display' | grep -Eiq '\[10de:'; then
    echo "-> NVIDIA GPU found, installing nvidia-driver"
    apt install nvidia-driver -y
fi

echo ""
echo "---- Configuring Automatic Login ----"
conf="/etc/lightdm/lightdm.conf"

current=$(sudo sed -n 's/^[[:space:]]*autologin-user[[:space:]]*=[[:space:]]*//p' "$conf" | head -n1)

if [[ "$current" != "$username" ]]; then
    if sudo grep -qE '^[[:space:]]*autologin-user[[:space:]]*=' "$conf"; then
        sudo sed -i "s/^[[:space:]]*autologin-user[[:space:]]*=.*/autologin-user=$username/" "$conf"
    else
        sudo tee -a "$conf" > /dev/null <<EOF

[Seat:*]
autologin-user=$username
EOF
    fi
fi

echo ""
echo "---- Creating Autostart Script ----"

sudo tee $autoStartScript > /dev/null <<EOF
#!/bin/bash
xset -dpms
xset s off
xset s noblank

while true
do
    chromium --kiosk --disable-infobars --noerrdialogs $url
    sleep 2
done
EOF
echo "-> Written to $autoStartScript"
chmod +x $autoStartScript

echo ""
echo "---- Configuring Autostart in Kiosk Mode ----"
mkdir -p "$autoStartDir"
tee "$autoStartFile" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=$autoStartScript
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Foundry
EOF
echo "-> Written to $autoStartFile"

echo ""
echo "---- Disabling Power Manager ----"
uid=$(id -u "$username")

systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

sudo -u "$username" \
    env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false

sudo -u "$username" \
    env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0

sudo -u "$username" \
    env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -s 0

echo ""
echo "---- Optimizing Boot Time ----"
#Disable unnecessary services
systemctl disable bluetooth
systemctl disable cups
systemctl disable avahi-daemon

#Setting GRUB timeout
if [[ "$hideGrub" == "y" || "$hideGrub" == "Y" ]]; then
    echo "-> Hiding GRUB"
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub

    if ! grep -qE '^[[:space:]]*GRUB_TIMEOUT_STYLE=' /etc/default/grub; then
        echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub > /dev/null
    fi

    update-grub
fi

echo ""
echo "---- Installation Ready ----"
read -p "Would you like to reboot now? (y/n): " rebootNow

if [[ "$rebootNow" == "y" || "$rebootNow" == "Y" ]]; then
    echo "Rebooting in 5 seconds"
    wait 5
    reboot
fi

echo ""
echo "---- Done! ----"
