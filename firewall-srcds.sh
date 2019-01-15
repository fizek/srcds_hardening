#!/bin/bash

LOG="LOG --log-level debug --log-tcp-sequence --log-tcp-options"
LOG="$LOG --log-ip-options"
RLIMIT="-m limit --limit 3/s --limit-burst 8"

/sbin/iptables -t nat -P PREROUTING ACCEPT
/sbin/iptables -t nat -P OUTPUT ACCEPT
/sbin/iptables -t nat -P POSTROUTING ACCEPT

/sbin/iptables -t mangle -P PREROUTING ACCEPT
/sbin/iptables -t mangle -P INPUT ACCEPT
/sbin/iptables -t mangle -P FORWARD ACCEPT
/sbin/iptables -t mangle -P OUTPUT ACCEPT
/sbin/iptables -t mangle -P POSTROUTING ACCEPT

/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -t mangle -F

/sbin/iptables -X
/sbin/iptables -t nat -X
/sbin/iptables -t mangle -X

/sbin/iptables -Z
/sbin/iptables -t nat -Z
/sbin/iptables -t mangle -Z

/sbin/iptables -N ACCEPTLOG
/sbin/iptables -A ACCEPTLOG -j $LOG $RLIMIT --log-prefix "srcds_itp ACCEPT "
/sbin/iptables -A ACCEPTLOG -j ACCEPT

/sbin/iptables -N DROPLOG
/sbin/iptables -A DROPLOG -j $LOG $RLIMIT --log-prefix "srcds_itp DROP "
/sbin/iptables -A DROPLOG -j DROP

/sbin/iptables -N REJECTLOG
/sbin/iptables -A REJECTLOG -j $LOG $RLIMIT --log-prefix "srcds_itp REJECT "
/sbin/iptables -A REJECTLOG -p tcp -j REJECT --reject-with tcp-reset
/sbin/iptables -A REJECTLOG -j REJECT

/sbin/iptables -N RELATED_ICMP
/sbin/iptables -A RELATED_ICMP -p icmp --icmp-type destination-unreachable -j ACCEPT
/sbin/iptables -A RELATED_ICMP -p icmp --icmp-type time-exceeded -j ACCEPT
/sbin/iptables -A RELATED_ICMP -p icmp --icmp-type parameter-problem -j ACCEPT
/sbin/iptables -A RELATED_ICMP -j DROPLOG

/sbin/iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j ACCEPT
/sbin/iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j $LOG --log-prefix "srcds_itp PING-DROP:"
/sbin/iptables -A INPUT -p icmp -j DROP
/sbin/iptables -A OUTPUT -p icmp -j ACCEPT
/sbin/iptables -A INPUT -p icmp --fragment -j DROPLOG
/sbin/iptables -A OUTPUT -p icmp --fragment -j DROPLOG
/sbin/iptables -A FORWARD -p icmp --fragment -j DROPLOG

/sbin/iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT $RLIMIT
/sbin/iptables -A OUTPUT -p icmp -m state --state ESTABLISHED -j ACCEPT $RLIMIT
/sbin/iptables -A INPUT -p icmp -m state --state RELATED -j RELATED_ICMP $RLIMIT
/sbin/iptables -A OUTPUT -p icmp -m state --state RELATED -j RELATED_ICMP $RLIMIT
/sbin/iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT $RLIMIT
/sbin/iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT $RLIMIT
/sbin/iptables -A INPUT -p icmp --icmp-type 3 -j ACCEPT $RLIMIT
/sbin/iptables -A OUTPUT -p icmp --icmp-type 3 -j ACCEPT $RLIMIT

/sbin/iptables -A INPUT -p icmp -j DROPLOG
/sbin/iptables -A OUTPUT -p icmp -j DROPLOG
/sbin/iptables -A FORWARD -p icmp -j DROPLOG

/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

/sbin/iptables -A INPUT -p tcp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP
/sbin/iptables -A INPUT -p udp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP
/sbin/iptables -A INPUT -m state --state INVALID -j DROP
/sbin/iptables -A OUTPUT -m state --state INVALID -j DROP
/sbin/iptables -A FORWARD -m state --state INVALID -j DROP
/sbin/iptables -A INPUT -m state --state NEW -p tcp --tcp-flags ALL ALL -j DROP
/sbin/iptables -A INPUT -m state --state NEW -p tcp --tcp-flags ALL NONE -j DROP

/sbin/iptables -N SYN_FLOOD
/sbin/iptables -A INPUT -p tcp --syn -j SYN_FLOOD
/sbin/iptables -A SYN_FLOOD -m limit --limit 2/s --limit-burst 6 -j RETURN
/sbin/iptables -A SYN_FLOOD -j DROP

/sbin/iptables -A INPUT -s 169.254.0.0/16 -j DROP
/sbin/iptables -A INPUT -s 172.16.0.0/12 -j DROP
/sbin/iptables -A INPUT -s 127.0.0.0/8 -j DROP
/sbin/iptables -A INPUT -s 224.0.0.0/4 -j DROP
/sbin/iptables -A INPUT -d 224.0.0.0/4 -j DROP
/sbin/iptables -A INPUT -s 240.0.0.0/5 -j DROP
/sbin/iptables -A INPUT -d 240.0.0.0/5 -j DROP
/sbin/iptables -A INPUT -s 0.0.0.0/8 -j DROP
/sbin/iptables -A INPUT -d 0.0.0.0/8 -j DROP
/sbin/iptables -A INPUT -d 239.255.255.0/24 -j DROP
/sbin/iptables -A INPUT -d 255.255.255.255 -j DROP

/sbin/iptables -A INPUT -p udp -m multiport --dports 16000:45000 -m length --length 0:32 -j LOG --log-prefix "srcds_itp SRCDS-XSQUERY " --log-ip-options -m limit --limit 1/m --limit-burst 1
/sbin/iptables -A INPUT -p udp -m multiport --dports 16000:45000 -m length --length 0:32 -j DROP

/sbin/iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

/sbin/iptables -A INPUT -j REJECTLOG
/sbin/iptables -A OUTPUT -j REJECTLOG
/sbin/iptables -A FORWARD -j REJECTLOG

exit 0
