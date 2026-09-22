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