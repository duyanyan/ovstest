sed -i 's/rhsm.redhat/rhsm.stage.redhat/g' /etc/rhsm/rhsm.confsubscription-manager register --username=$USERNAME --password=$PASSWORD
subscription-manager refresh
subscription-manager list --av
subscription-manager attach --pool 8a99f9a56df804d9016dfbddd2130a1f
subscription-manager repos --disable "*"
# Configure repo
cat > /etc/yum.repos.d/nm.repo << EOF
[nm]
name=nm
baseurl=http://se-sat6.cloud.lab.eng.bos.redhat.com/pub/nm-7.7-rpms/
metadata_expire=1
enabled=1
gpgcheck=0
failovermethod=priority
sslverify=0EOF
# Install packages
yum install -y NetworkManager-1.18.0-5.el7_7.1.1.bz1740557.x86_64 NetworkManager-ovs-1.18.0-5.el7_7.1.1.bz1740557.x86_64subscription-manager repos --enable=rhel-7-fast-datapath-rpms
subscription-manager repos --enable rhel-7-server-optional-rpmssudo yum -y install NetworkManager-ovs openvswitch2.11.x86_64setenforce 0
systemctl daemon-reload;systemctl restart NetworkManager;systemctl enable openvswitch;systemctl start openvswitch
