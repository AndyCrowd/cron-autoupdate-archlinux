#!/bin/bash
 if [ ! -f /tmp/.updated_down_all ];then
 if [ ! -z "$(pidof Xorg.bin)"  ];then export DISPLAY=":0"  ;fi
  if [ ! -z $DISPLAY ];then
   TI=$(xprintidle)
  else
   PreTIm=$(w | grep "$(whoami)" | awk '{print $4}' | awk -F':' '{if ( $2 ~ "m" ){ A=$1; split(A,B,":");print B[1]} }')
   PreTIh=$(w | grep "$(whoami)" | awk '{print $4}' | awk -F':' '{if ( $2 ~ "h" ){ A=$1; split(A,B,":");print B[1]} }')
   PreTIs=$(w | grep "$(whoami)" | awk '{print $4}' | awk -F'.' '{if ( $2 ~ "s" ){ A=$1; split(A,B,".");print B[1]} }')
   if [ ! -z "$PreTIh"  ];then TI=$((PreTIh * 3600000i));fi
   if [ ! -z "$PreTIm"  ];then TI=$((PreTIm * 60000 ));fi
   if [ ! -z "$PreTIs"  ];then TI=$((PreTIs * 1000 ));fi
  fi
#MAXw=$((3600000*3/2))
TI="20"
MAXw="10"
if [ "${TI}" -gt "${MAXw}" ]; then
if [ "$(/usr/local/bin/CheckPower.sh)" == "OK" ];then
#Test_Conn="$(ifconfig -a | grep -v -e ^' ' -e ^$ -e 'lo:' |  awk '{system("/sbin/ip -4 addr show dev "$1); system("/sbin/ip -6 addr show dev "$1)}' | grep inet | awk '{system("ping -c 1 "$2);}' | grep ' 0% ')"
 ping -c 1 8.8.8.8 > /dev/null
 if [ ${?} == "0" ];then
echo 'down=yes' > /tmp/.updated_down_all
pacman -Suw --noconfirm
pacman -Ss --noconfirm --needed $(pacman -Ssq | grep ^jre | grep 'openjdk'$)
yes | pacman -Su
if [ "${?}" != "0"  ];then beep -f 100 -l 1000 && zenity --warning --text="Ett problem har uppstått. Kontakta Andy!";
if [ -f "/var/lib/pacman/db.lck"  ];then zenity --warning --text="Databasfilen är skadat eller används: /var/lib/pacman/db.lck";fi;fi;
systemctl daemon-reload
pacman-db-upgrade
   fi
  fi
 fi
fi
