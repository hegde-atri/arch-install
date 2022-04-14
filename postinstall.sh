# get dwm + dotfiles

figlet -k "welcome $USER"
echo -ne "
-------------------------------
| Post install script
-------------------------------
"
sleep 2
figlet -k " WARNING"
echo -ne "
---------------------------------------------
|  This script only installs DWM as of now  |
|           press y to continue             |
|               or n to quit                |
---------------------------------------------
"
echo -n "Your response: "
read warn
if [ "$warn" == "n" ] ; then
  exit
fi

# prerequisites
sudo pacman -S --noconfirm --needed python-pywal figlet
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
  # configure .xinitrc
  xpath=$HOME/.xinitrc
  bpath=$HOME/.bashrc
  sudo pacman -S --needed --noconfirm xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
  cp /etc/X11/xinit/xinitrc xpath
  sed -i 's/xclock -geometry 50x50-1+1 &/#xclock -geometry 50x50-1+1 &/g' xpath
  sed -i 's/xterm -geometry 80x50+494+51 &/#xterm -geometry 80x50+494+51 &/g' xpath
  sed -i 's/xterm -geometry 80x20+494-0 &/#xterm -geometry 80x20+494-0 &/g' xpath
  sed -i 's/exec xterm -geometry 80x66+0+0 -name login/#exec xterm -geometry 80x66+0+0 -name login/g' xpath
  sed -i 's/twm &//g' xpath
  echo "" >> xpath
  echo "wal -R" >> xpath
  echo "twm &" >> xpath
  echo "exec dwm" >> xpath

  # create symlinks
  mkdir $HOME/.local/bin/statusbar
  cp --symbolic-link $HOME/source/dwmblocks-async/scripts/* $HOME/.local/bin/statusbar
  mkdir 
  cp $HOME/source/dwm/autostart.sh $HOME/.dwm
  cp $HOME/source/dwm/autostart_blocking.sh $HOME/.dwm

  # pywal fix
  echo "" >> bpath
  echo "# pywal fix" >> bpath
  echo "(cat ~/.cache/wal/sequences &)" >> bpath
  echo "cat ~/.cache/wal/sequences" >> bpath
  echo "source ~/.cache/wal/colors-tty.sh" >> bpath
  echo ". "${HOME}/.cache/wal/colors.sh"" >> bpath
  echo "#status bar scripts" >> bpath
  echo "export PATH="$HOME/.local/bin/statusbar:$PATH"" >> bpath
  echo "# dwm-pywal fix" >> bpath
  echo "sed -i '/urg/d' ~/.cache/wal/colors-wal-dwm.h" >> bpath

  figlet -k "DONE"
  echo -ne "
  -----------------------------------------------
  |         Log out and log back in to          |
  |           refresh path locations!           |
  |     Then use command startx to launch dwm   |
  -----------------------------------------------
  "
  sleep 5
  exit
else
  echo "------------------------------------------"
  echo "| You can now delete me ~/postinstall.sh |"
  echo "------------------------------------------"
  figlet -k "Thanks for using me"
  figlet -k "Star my github repo"
  sleep 3
  exit
fi
