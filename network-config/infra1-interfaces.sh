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

auto br-mgmt
iface br-mgmt inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens3
    address 172.29.236.11
    netmask 255.255.252.0
    gateway 172.29.236.1
    dns-nameservers 8.8.8.8 8.8.4.4

auto br-vxlan
iface br-vxlan inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens8

auto br-storage
iface br-storage inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports ens9