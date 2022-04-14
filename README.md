# My Arch installer

Deploys arch on target system. Use postinstallation script to install a Desktop environment or DWM.

This script it not intended for complete beginners. Make sure to be familiar with installing arch or read through the arch installation guide.

Only supports efi installs.

## Usage

After booting into your arch live ISO, make sure you have a working internet connection.

- You can test your connection using the ping command. `ping gnu.org`. If you want to use wifi then use the built in `iwctl` utility.
- We need git installed to get this repository. `pacman -Sy git`
- Clone this repo `git clone https://github.com/hegde-atri/arch-install.git`
- Now get into the directory with `cd arch-install` and execute the script `sh archinstall.sh`
