# get dwm + dotfiles

figlet -k "welcome $USER"
echo -ne "
-------------------------------
| Post install script
-------------------------------
"

# prerequisites
sudo pacman -S --noconfirm python-pywal figlet
mkdir ~/source
git clone --depth=1 https://github.com/hegde-atri/wallpapers.git ~/.wallpapers
wal -i ~/.wallpapers/aesthetic/wallhaven-gjyoq7.png
sed -i '/urg/d' ~/.cache/wal/colors-wal-dwm.h # as we don't have the urgent patch for dwm

printf '\033c'
figlet -k "DWM"
echo -ne "
-------------------------------------------
| Look at ~/source/dwm/config.h file for  |
| keybinds. MOD key is the super/win key  |
-------------------------------------------
"
sleep 5
# dwm - tiling window manager
git clone --depth=1 https://github.com/hegde-atri/dwm.git ~/source/dwm
sed -i 's/#include \"\/home\/mizuuu\/.cache\/wal\/colors-wal-dwm.h\"/#include \"\/home\/"$USER"\/.cache\/wal\/colors-wal-dwm.h\"/g' ~/source/dwm/config.h
sudo make -C ~/source/dwm install

# dmenu - program menu / program launcher
git clone --depth=1 https://github.com/hegde-atri/dmenu.git ~/source/dmenu
sudo make -C ~/source/dmenu install

# dwmblocks-async - status bar for dwm
git clone --depth=1 https://github.com/hegde-atri/dwmblocks-async.git ~source/dwmblocks-async
sudo make -C ~/source/dwmblocks-async install

figlet -k "!!IMPORTANT!! READ BELOW"
echo "-------------------------------------------"
echo "| If you are not going to use my dotfiles |"
echo "|  or do not know what dotfiles are then  |"
echo "|    type y in the next prompt, type      |"
echo "|         anything else to quit           |"
echo "-------------------------------------------"
echo -n "Your response: "
read response
if [ "$response" == "y" ] ; then




else
  echo "------------------------------------------"
  echo "| You can now delete me ~/postinstall.sh |"
  echo "------------------------------------------"
  figlet -k "Thanks for using me"
  figlet -k "Star my github repo"
  sleep 3
  exit
fi
