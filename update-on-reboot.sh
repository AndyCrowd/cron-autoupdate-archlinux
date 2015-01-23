#!/bin/bash

if [ -f "/var/lib/pacman/db.lck" ];then rm /var/lib/pacman/db.lck ;fi

ST=($(upower -i "$(upower -e | grep 'BAT')" | grep -e "state" -e percentage | awk '{print $2}' | sed 's/%//g'))
if [ -z ${ST[0]} ];then ST[0]="No_battery";ST[1]="100";
fi

if [ ${ST[1]} -gt 60 ]  || [ ${ST[0]} == 'charging' ] || [ ${ST[0]} == 'fully-charged' ]; then

if [ "$(/usr/local/bin/CheckPower.sh)" == "OK" ];then

pacman -S --needed --noconfirm  $(/usr/local/bin/NeededToUpdate.sh)
sleep 1
systemctl daemon-reload
sleep 2
#paccache -rk2
#paccache -ru
pacman-db-upgrade
#aplay /usr/share/sounds/pop.wav
/usr/share/hunspell/CleanSpell.sh
/usr/lib/aspell-0.60/CleanSpell.sh
/usr/share/myspell/dicts/CleanSpell.sh
fi
fi
