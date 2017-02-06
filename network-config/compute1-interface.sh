# The loopback network interface
auto lo
iface lo inet loopback

# Container/Host management interface
auto ens3
iface ens3 inet manual

# OpenStack Networking VXLAN (tunnel/overlay) interface
auto ens8
iface ens8 inet manual

# Storage network interface
auto ens9
iface ens9 inet manual

# Container/Host management bridge
auto br-mgmt
iface br-mgmt inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens3
    address 172.29.236.12
    netmask 255.255.252.0
    gateway 172.29.236.1
    dns-nameservers 8.8.8.8 8.8.4.4

# compute1 VXLAN (tunnel/overlay) bridge config
auto br-vxlan
iface br-vxlan inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens8
    address 172.29.240.12
    netmask 255.255.252.0

# compute1 Storage bridge
auto br-storage
iface br-storage inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens9
    address 172.29.244.12
    netmask 255.255.252.0