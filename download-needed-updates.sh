#!/bin/bash

IdleTimeout(){

#beep -f 3000
if [ ! -z $DISPLAY ];then
TI=$(xprintidle)
else
PreTIm=$(w | grep $(whoami) | awk '{print $4}' | awk -F':' '{if ( $2 ~ "m" ){ A=$1; split(A,B,":");print B[1]} }')
PreTIh=$(w | grep $(whoami) | awk '{print $4}' | awk -F':' '{if ( $2 ~ "h" ){ A=$1; split(A,B,":");print B[1]} }')
PreTIs=$(w | grep $(whoami) | awk '{print $4}' | awk -F'.' '{if ( $2 ~ "s" ){ A=$1; split(A,B,".");print B[1]} }')

if [ ! -z "$PreTIh"  ];then
TI=$((PreTIh * 3600000 ))
return $TI
else

if [ ! -z "$PreTIm"  ];then
TI=$((PreTIm * 60000 ))
return $TI
else

if [ ! -z "$PreTIs"  ];then
TI=$((PreTIs * 1000 ))

else
return 3600001
#echo 3600001
fi
fi
fi
fi

}

########### END  IdleTimeout

CheckIP(){

#beep -f 1000
#Ping_own_IP=$(ifconfig -a | grep -v -e ^' ' -e ^$ -e 'lo:' |  awk '{system("/sbin/ip -4 addr show dev "$1); system("/sbin/ip -6 addr show dev "$1)}' | grep inet | awk '{system("ping -c 1 "$2);}' | grep ' 0% ' -c )

G_own_IP=$(ifconfig -a | grep -v -e ^' ' -e ^$ -e 'lo:' |  awk '{system("/sbin/ip -4 addr show dev "$1); system("/sbin/ip -6 addr show dev "$1)}' | grep inet | awk '{if( $3 == "peer")print  $2}')

if [ ! -z ${G_own_IP}  ]; then 
return 0
#echo OK;
else 
return 1
echo Fail;
fi

}

########### END CheckIP

CheckPower(){

#beep -f 2000
MAXpower="60"

ST=($(upower -i "$(upower -e | grep 'BAT')" | grep -e "state" -e percentage | awk '{print $2}' | sed 's/%//g'))
if [ ! -z ${ST[0]} ];then

if [ ${ST[1]} -gt ${MAXpower} ]  || [ ${ST[0]} == 'charging' ] || [ ${ST[0]} == 'fully-charged' ]; then
return 0
#echo "OK"
else
return 1
#echo "Fail"
fi
else 
return 0
#echo "OK"
fi

}

########### END CheckPower

if [[ -f "/var/lib/pacman/db.lck" && -z "$(pidof pacman)"  ]];then 

AA=$(pidof pacman)
if [ -z "$AA" ]; then
rm /var/lib/pacman/db.lck ;
unset AA
else
exit 1
fi

fi

####################
if [ ! -f /tmp/.updated_down_needed ];then  
####################

##################
#echo 'down=yes' > /tmp/.updated_down_needed

TI="$(IdleTimeout.sh)"
TI=20
#MAXw="3600000"
MAXw=10

CheckIP
ifMyIPok=$?

CheckPower
ifMyPWRok=$?

#ifMyIPok="$(CheckIP.sh)"
#ifMyPWRok="$(CheckPower.sh)"
 ping -c 1 8.8.8.8 > /dev/null ;
 if [ "${?}" == "0"  ]; then
# Test_Conn="OK"
 IS_Conn=0
 fi
###########################
###########################

#echo "${ifMyIPok}" '${ifMyIPok}'
#echo "${ifMyPWRok}" '${ifMyPWRok}'
#echo "${IS_Conn}" '${IS_Conn}'

#if [[ "${ifMyIPok}" == 'OK' && "${ifMyPWRok}" == 'OK' && ${IS_Conn} == 'OK'  ]] ;then 
if [[ "${ifMyIPok}" && "${ifMyPWRok}" && ${IS_Conn} == '0'  ]] ;then
OKOK='OK'
else 
OK_OK='Fail'
fi

   if [ "${TI}" -gt "${MAXw}" ]; then
STARTit=$(date '+%M-%S')

xmessage -timeout 2 "Starting downloading of updates" & disown
#echo $OK_OK

    if [ "${OKOK}" == "OK" ]; then
echo 'down=yes' > /tmp/.updated_down_needed

xmessage -timeout 3 "Started updating" & disown

pacman-db-upgrade

pacman -Sy --noconfirm

yes | pacman -S --needed --noconfirm $(pacman -Ssq | grep -e ^jre -e ^jdk | grep 'openjdk'$ )

/usr/local/bin/NeededToUpdate.sh | pacman -Sw --noconfirm --needed -
SSS=$?
sleep 1
pacman-db-upgrade
#echo 'down=yes' > /tmp/.updated_down_needed
ENDit="$(date '+%M-%S')"
xmessage -timeout 3 "${STARTit}"' * '"${ENDit}" & disown
#beep -f 90
#beep -f 50
    fi
   fi
  fi
