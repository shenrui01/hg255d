#!/bin/sh
# /usr/lib/dynamic_dns/dynamic_dns_updater.sh
#
# Written by zjhzzyf, 20110303
#
# http://www.openwrt.org.cn/
#


. /etc/functions.sh


INTERFACE=${INTERFACE}

update_ipaddress(){

  [ -n "$service_name" ]&&update_url=$(cat /usr/lib/ddns/services |grep $service_name|awk -F " " '{print $2}')
# neiwang
    [ "$neiwang" == "1" ]&& {
        if [ -n "$ip_network" ]; then
        num=`echo $ip_network | tr -d "wan"`
        if [ -z $num ] ; then num=0; fi  
        wanrule=$((($num+1)*10)) 
        fi
   local ddnsipd=$(cat /tmp/ddnsipd)
   [ -n "$ddnsipd" ]&& eval $ddnsipd
        iptables -t mangle -A ASSIGNOUT -d ip.3322.net -j MARK --set-mark $wanrule
        iptables -t mangle -A ASSIGNOUT -d  checkip.dyndns.org -j MARK --set-mark $wanrule
#http://ip.3322.net
   echo  "iptables -t mangle -D ASSIGNOUT -d ip.3322.net -j MARK --set-mark $wanrule" >/tmp/ddnsipd
  echo  "iptables -t mangle -D ASSIGNOUT -d checkip.dyndns.org -j MARK --set-mark $wanrule" >/tmp/ddnsipd
 
[ $(echo $service_name |grep -v 3322 ) ]||ipaddr=$( echo `wget -q -O- http://ip.3322.net/`|grep -o "$ip_regex")
[ $(echo $service_name |grep -v dyndns ) ]|| ipaddr=$(echo `wget -q -O- http://checkip.dyndns.org/`|grep -o "$ip_regex")
  }


 #change username
 
 update_url=$(echo $update_url | sed s/"\[USERNAME\]"/"$username"/g)
  #change password
 update_url=$(echo $update_url | sed s/"\[PASSWORD\]"/"$password"/g)
  #change domain
 update_url=$(echo $update_url | sed s/"\[DOMAIN\]"/"$domain"/g)
  #change ipaddr
  update_url=$(echo $update_url | sed s/"\[IP\]"/"$ipaddr"/g)  
  #delete ""
  update_url=$(echo $update_url | sed s/"\""/""/g)  
  #update  ipaddr 
  echo "wget -q -O- $update_url" 
    
  wget -t 2 -T 10 -q -O- $update_url 
  nowtime=`date +%c`
#echo `wget -q -O- http://checkip.dyndns.org/`|grep -o "$ip_regex"

 uci set ddns.$section.uptime="$nowtime"
 uci set ddns.$section.ipaddr="$ipaddr"
 uci commit ddns
  
	}


ddns_goble_get(){
	 config_get enabled $1 enabled
	 config_get check_interval $1 check_interval
	# echo "1=$enabled 2=$check_interval" 

# add crontabs task 
#. /lib/cron/common.sh	 
	if  [ "$enabled" == "1" -a "$check_interval" != "0" ]; then 
delete_task ddns_scheduler
add_task ddns_scheduler "/usr/lib/ddns/dynamic_dns_updater.sh scheduler" ${check_interval}
	else 
delete_task ddns_scheduler
	fi

}
	 

ddns_service_get(){
	
 unset ipaddr	 
 unset update_url
 config_get enabled $1 enabled
 config_get neiwang $1 neiwang
 config_get service_name $1 service_name
 config_get domain $1 domain
 config_get username $1 username
 config_get password $1 password
 config_get ip_network $1 ip_network
 config_get update_url $1 update_url
 config_get uptime $1 uptime
 section=$1
	ip_regex="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" 
echo line 97
 [ "$enabled" == "1" ]&&{
	ipaddr=$(uci -P /var/state get network.${ip_network}.ipaddr)
	old_ipaddr=$(ping -c 1 $domain|head -1 | grep -o "$ip_regex")

 [ -z "$ipaddr" ]&&exit 0
#  echo "enabled=$enabled old_ipaddr=$old_ipaddr ipaddr=$ipaddr"

 #ifup update ip
if [ "$isifup" == "1" -a "$ip_network" = "$INTERFACE" ];then
 update_ipaddress
fi 

 # scheduler update ip
 if [ "$ipaddr" != "$old_ipaddr" ];then
update_ipaddress
 fi
 }
 
}

 config_load ddns
 config_foreach oscam_conf conf

case "$1" in
	start )
		 config_foreach ddns_goble_get goble
		 config_foreach ddns_service_get service
		;;
	stop )
		echo "stop"
		;;
	scheduler )
		config_foreach ddns_service_get service
		;;
	ifup )
	 local isifup
	 isifup=1
	 config_foreach ddns_service_get service
		;;

esac







