#!/bin/bash -ex
#
source config.cfg

echo "########## CAI DAT NOVA TREN CONTROLLER ##########"
sleep 5 
apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

######## SAO LUU CAU HINH cho NOVA ##########"
sleep 7

#
controlnova=/etc/nova/nova.conf
test -f $controlnova.orig || cp $controlnova $controlnova.orig
rm $controlnova
touch $controlnova
cat << EOF >> $controlnova
[DEFAULT]
verbose = True

dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
libvirt_use_virtio_for_bridges=True
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
enabled_apis=ec2,osapi_compute,metadata

# Khai bao cho RabbitMQ
rpc_backend = rabbit
rabbit_host = $CON_MGNT_IP
rabbit_password = $RABBIT_PASS

auth_strategy = keystone

my_ip = $CON_MGNT_IP

vncserver_listen = $CON_MGNT_IP
vncserver_proxyclient_address = $CON_MGNT_IP

[glance]
host = $CON_MGNT_IP

[database]
connection = mysql://nova:$NOVA_DBPASS@$CON_MGNT_IP/nova

[keystone_authtoken]
auth_uri = http://$CON_MGNT_IP:5000/v2.0
identity_uri = http://$CON_MGNT_IP:35357
admin_tenant_name = service
admin_user = nova
admin_password = $NOVA_PASS

EOF

echo "########## XOA FILE DB MAC DINH ##########"
sleep 7
rm /var/lib/nova/nova.sqlite

echo "########## DONG BO DB CHO NOVA ##########"
sleep 7 
nova-manage db sync

# fix loi libvirtError: internal error: no supported architecture for os type 'hvm'
echo 'kvm_intel' >> /etc/modules

echo "########## KHOI DONG LAI NOVA ##########"
sleep 7 
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
sleep 7 
echo "########## KHOI DONG NOVA LAN 2 ##########"
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

echo "########## KIEM TRA LAI DICH VU NOVA ##########"
nova-manage service list

