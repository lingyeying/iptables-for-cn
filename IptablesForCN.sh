#!/bin/sh

function initIpset(){
    _ips=$2
    _ips=${_ips//[[:blank:]]/}
    ipset_name=$1
    if ipset list | grep -q "\<$ipset_name\>"; then
        ipset flush $ipset_name
    else
        ipset create $ipset_name hash:net
    fi
    for _ip in $_ips;do
        _ip=${_ip%%#*}
        ipset add $ipset_name $_ip
    done
}

function initChinaIpset(){
    zoneFile=/tmp/cn-aggregated.zone
    zoneFileCur=/tmp/cn-aggregated.zone.cur
    wget --no-check-certificate https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone -O $zoneFile
    if cmp -s "$zoneFile" "$zoneFileCur"; then
        echo "cn zone has no change!"
        return 0
    fi
    if ipset list | grep -q "\<chinatmp\>"; then
        ipset flush chinatmp
    else
        ipset create chinatmp hash:net
    fi
    if ! ipset list | grep -q "\<china\>"; then
        ipset create china hash:net
    fi
    for i in $(cat $zoneFile ); do
        ipset -A chinatmp $i;
    done
    ipset swap china chinatmp
    ipset destroy chinatmp
    rm -f $zoneFileCur
    mv $zoneFile $zoneFileCur
}

## Ip ranges of local and other self needs
self_ips="
127.0.0.0/8
192.168.0.0/16
172.16.0.0/12
10.0.0.0/8
8.8.8.8#dns
"
iptables -F
initIpset self "$self_ips"
initChinaIpset

iptables -I INPUT -i lo -j ACCEPT
## Web Service
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
## SSH
iptables -A INPUT -p tcp --dport 22 -m set --match-set self src -j ACCEPT
## Returning Traffic
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
## Deny all else INPUT
iptables -A INPUT -j DROP

## Just allow to visit self and china ip ranges
# iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -d time.windows.com -j ACCEPT
iptables -A OUTPUT -m set --match-set self dst -j ACCEPT
iptables -A OUTPUT -m set --match-set china dst -j ACCEPT
## Allow response traffic from web service
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
iptables -A OUTPUT -j DROP
