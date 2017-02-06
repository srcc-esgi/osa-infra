# Définir un environement
# environement de test simple :
# infra1 : host d'infrastructure
# compute1 : host compute et storage

# Sur tous les hosts
apt-get update
apt-get dist-upgrade -y
apt-get install aptitude build-essential git ntp ntpdate \
  openssh-server python-dev sudo -y
apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
  lsof lvm2 ntp ntpdate openssh-server sudo tcpdump vlan -y
echo 'bonding' >> /etc/modules
echo '8021q' >> /etc/modules

# Configurer le réseau
vim /etc/network/interfaces # copier/s'inspirer des fichiers *-interfaces.sh ci-joints
brctl addbr br-mgmt
brctl addbr br-vxlan
brctl addbr br-storage
systemctl restart networking
ping -c 3 google.com # Si ça ping c'est bon

# Sur l'host de deploiement
git clone -b stable/newton https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible && scripts/bootstrap-ansible.sh
cp -r /opt/openstack-ansible/etc/openstack_deploy /etc/openstack_deploy

# Configuration openstack ansible
cp /etc/openstack_deploy/openstack_user_config.yml.example /etc/openstack_deploy/openstack_user_config.yml
vim /etc/openstack_deploy/openstack_user_config.yml # http://docs.openstack.org/project-deploy-guide/openstack-ansible/newton/app-config-test.html

# Configurer les clefs ssh depuis l'host de deploiement vers tous les hosts puis :
cd /opt/openstack-ansible/playbooks
openstack-ansible setup-infrastructure.yml --syntax-check
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml