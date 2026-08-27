#!/usr/bin/env bash
# iptables-rules.sh
# Hardened iptables rules for Air-Gapped and Shared Network topologies

# Flush all existing rules and custom chains
iptables -F
iptables -X

# Set default policies to DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic (required for internal services and Docker DNS)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections (stateful inspection)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow inbound HTTP and HTTPS traffic from the local subnet (adjust IP range as needed)
# Example: 192.168.1.0/24 is the authorized local subnet.
LOCAL_SUBNET="192.168.1.0/24"
iptables -A INPUT -p tcp -s $LOCAL_SUBNET -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

# Allow outbound traffic for NTP (UDP 123) for time synchronization (critical for Air-Gapped fallback if NTP server exists)
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT

# Drop all other traffic (handled by default policies, but adding explicit log and drop can be useful for auditing)
# iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: "
# iptables -A INPUT -j DROP

# NOTE: Docker modifies iptables rules automatically.
# You may need to set "iptables": false in Docker's daemon.json
# or carefully integrate these rules with Docker's DOCKER-USER chain.