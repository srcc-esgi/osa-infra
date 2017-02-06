# Guide de déploiement d'OSA-Newton

## Mise en place de la plateforme

Définir un environement tel que celui-ci :
- un host "infra1" : il servira aussi d'host de déploiment. Ses ips se termineront en .11
- un host "compute1". Ses ips se termineront en .12

## Mise en place du réseau

**RMQ : ne pas oublier de remplacer le nom des interfaces par celle des machines de l'environement, si diférentes.**

### Cas 1 : une seule interface physique

Si les hosts ne possèdent qu'une seule interface physique, alors :

#### Sur infra1 :
```` bash
# Physical interface
auto eth0
iface eth0 inet manual

# Container/Host management VLAN interface
auto eth0.10
iface eth0.10 inet manual
    vlan-raw-device eth0

# OpenStack Networking VXLAN (tunnel/overlay) VLAN interface
auto eth0.30
iface eth0.30 inet manual
    vlan-raw-device eth0

# Storage network VLAN interface (optional)
auto eth0.20
iface eth0.20 inet manual
    vlan-raw-device eth0

# Container/Host management bridge
auto br-mgmt
iface br-mgmt inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.10
    address 172.29.236.11
    netmask 255.255.252.0
    gateway 172.29.236.1                             # Adapter selons la gateway
    dns-nameservers 8.8.8.8 8.8.4.4

# OpenStack Networking VXLAN (tunnel/overlay) bridge
auto br-vxlan
iface br-vxlan inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.30

# OpenStack Networking VLAN bridge
auto br-vlan
iface br-vlan inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0

# Storage bridge (optional)
auto br-storage
iface br-storage inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.20
````


#### Sur compute1 :

```` bash
# Physical interface
auto eth0
iface eth0 inet manual

# Container/Host management VLAN interface
auto eth0.10
iface eth0.10 inet manual
    vlan-raw-device eth0

# OpenStack Networking VXLAN (tunnel/overlay) VLAN interface
auto eth0.30
iface eth0.30 inet manual
    vlan-raw-device eth0

# Storage network VLAN interface (optional)
auto eth0.20
iface eth0.20 inet manual
    vlan-raw-device eth0

# Container/Host management bridge
auto br-mgmt
iface br-mgmt inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.10
    address 172.29.236.12
    netmask 255.255.252.0
    gateway 172.29.236.1                             # Adapter selons la gateway
    dns-nameservers 8.8.8.8 8.8.4.4

# OpenStack Networking VXLAN (tunnel/overlay) bridge
auto br-vxlan
iface br-vxlan inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.30
    address 172.29.240.12
    netmask 255.255.252.0

# OpenStack Networking VLAN bridge
auto br-vlan
iface br-vlan inet manual
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0

# Storage bridge (optional)
auto br-storage
iface br-storage inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports eth0.20
    address 172.29.244.12
    netmask 255.255.252.0
````

**Création des bridges et vérification du réseau**
```` bash
brctl addbr br-mgmt
brctl addbr br-vxlan
brctl addbr br-storage
systemctl restart networking
ping -c 3 google.com # Si ça ping c'est bon
````

### Cas 2 : plusieurs interfaces physiques

Si les hosts possèdent au moins trois interfaces, alors :
- ens3 : sera l'interface de gestion des containers. 172.29.236.0/22
- ens8 : sera l'interface du réseau overlay d'OpenStack. 172.29.240.0/22
- ens9 : sera l'interface de gestion du stockage d'OpenStack. 172.29.244.0/22

#### Sur infra1 :
Editer le fichier ````/etc/network/interfaces```` comme il suit :
```` bash
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
````

#### Sur compute1:
Editer le fichier ````/etc/network/interfaces```` comme il suit :
```` bash
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
````

**Création des bridges et vérification du réseau**
```` bash
sudo -i
brctl addbr br-mgmt
brctl addbr br-vxlan
brctl addbr br-storage
systemctl restart networking
ping -c 3 google.com
````

## Préparation de l'environement

### Création des clefs RSA

Sur infra1 :  
```` bash
sudo -i
ssh-keygen -t rsa -b 2048
ssh compute1 "mkdir .ssh"
scp .ssh/id_rsa.pub compute1:~/.ssh/authorized_keys
ssh compute1
````
### Installation des dépendances

Sur infra1 et compute1 :  
```` bash
sudo -i
apt-get update
apt-get dist-upgrade -y
apt-get install aptitude build-essential git ntp ntpdate \
  openssh-server python-dev sudo -y
apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
  lsof lvm2 ntp ntpdate openssh-server sudo tcpdump vlan -y
echo 'bonding' >> /etc/modules
echo '8021q' >> /etc/modules
````

### Sur l'host de deploiement
```` bash
sudo -i
git clone -b stable/newton https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible && scripts/bootstrap-ansible.sh
cp -r /opt/openstack-ansible/etc/openstack_deploy /etc/openstack_deploy
````

### Configuration openstack ansible
```` bash
sudo -i
cp /etc/openstack_deploy/openstack_user_config.yml.example /etc/openstack_deploy/openstack_user_config.yml
vim /etc/openstack_deploy/openstack_user_config.yml # http://docs.openstack.org/project-deploy-guide/openstack-ansible/newton/app-config-test.html
````

### Lancement des playbooks :
```` bash
# 0. Passer root
sudo -i

# 1. Génération des mots de passe et secrets. Ils seront stockés dans /etc/openstack_deploy/*_secrets.yml
cd /opt/openstack-ansible/scripts
python pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

# 2. Lancement des playbooks
cd /opt/openstack-ansible/playbooks

# 2.1 Vérification syntaxique
openstack-ansible setup-infrastructure.yml --syntax-check

# 2.2 Playbook de déploiement des containers
openstack-ansible setup-hosts.yml

# 2.3.1 Playbook de configuration de l'infrastructure
openstack-ansible setup-infrastructure.yml

# 2.3.2 Vérification
ansible galera_container -m shell \
  -a "mysql -h localhost -e 'show status like \"%wsrep_cluster_%\";'"

# 2.4 Installation d'OpenStack
openstack-ansible setup-openstack.yml
````