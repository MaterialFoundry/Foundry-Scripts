# Foundry-Scripts

## Foundry Client Minimal Install
Configures a dedicated minimal Linux installation to:

* Automatically login
* Launch Chromium
* Load a configured Foundry server
* If browser crashes -> relaunch Chromium

Tested on Debian 13

Installation:

* Install [Debian 13 Netinstall](https://www.debian.org/CD/netinst/) on the system. During installation only select:
    * XFCE Desktop
    * Standard System Utilities
    * SSH Server (if desired)
* After the install, add your user to the sudoers list: `sudo usermod -aG sudo username` (replace `username` with your username)
* Log out and back in
* Download the script: `wget https://github.com/MaterialFoundry/Foundry-Scripts/raw/refs/heads/main/foundry-minimal-install.sh`
* Make the script executable: `sudo chmod +x foundry-minimal-install.sh`
* Run the script: `sudo bash foundry-minimal-install.sh`
* When prompted, enter the URL to your Foundry server, e.g.: `http://192.168.1.10:30000`
* When prompted, choose whether you want to hide the GRUB screen on boot (will speed up boot time, but will make it harder to boot into anything other than this dedicated Foundry installation)
* The script will now install and configure everything. Enter `y` or `n`
* When the script is finished, it will ask you if you want to reboot or not, enter `y` or `n`