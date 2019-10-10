#!/bin/bash

echo 0 > /proc/sys/net/ipv4/ip_forward
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 1 > $i; done
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
for i in /proc/sys/net/ipv4/conf/*/log_martians; do echo 1 > $i; done
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/proxy_arp; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/secure_redirects; do echo 1 > $i; done
for i in /proc/sys/net/ipv4/conf/*/bootp_relay; do echo 0 > $i; done
