[![CodeFactor](https://www.codefactor.io/repository/github/hegde-atri/arch-install/badge)](https://www.codefactor.io/repository/github/hegde-atri/arch-install)

# My Arch installer

Deploys arch on target system. Configured to work on my devices. Feel free to fork this and customize it.

This script it not intended for complete beginners. Make sure to be familiar with installing arch or read through the arch installation guide.

Only supports efi installations.

Check my [arch guide (WIP)](https://arch-wiki.hegdeatri.com)

## Usage

After booting into your arch live ISO, make sure you have a working internet connection.

- You can test your connection using the ping command. `ping gnu.org`. If you want to use wifi then use the built in `iwctl` utility.
- We need git installed to get this repository. `pacman -Sy git`
- Clone this repo `git clone https://github.com/hegde-atri/arch-install.git`
- Now get into the directory with `cd arch-install` and execute the script `sh archinstall.sh`

## Disclaimer

This script does not have enough error checking, so make sure not to rush through it and be careful before pressing enter. This script is not intended for an easy/beginner install, it is to only help me to get my required config of arch up and running with most of the redundant commands automated.

## Contributing

Any feedback or pointers on how I could've made this better are always welcome !
