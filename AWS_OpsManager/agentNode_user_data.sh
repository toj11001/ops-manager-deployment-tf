#!/bin/sh -xe
sudo yum update -y
curl -OL ${mmsBaseUrl}/download/agent/automation/mongodb-mms-automation-agent-manager-latest.x86_64.rpm
sudo rpm -U mongodb-mms-automation-agent-manager-latest.x86_64.rpm
sudo rm /etc/mongodb-mms/automation-agent.config
sudo tee /etc/mongodb-mms/automation-agent.config <<EOF
mmsGroupId=${mmsGroupId}
mmsApiKey=${mmsApiKey}
mmsBaseUrl=${mmsBaseUrl}
logFile=/var/log/mongodb-mms-automation/automation-agent.log
mmsConfigBackup=/var/lib/mongodb-mms-automation/mms-cluster-config-backup.json
logLevel=INFO
maxLogFiles=10
maxLogFileSize=268435456
EOF
sudo yum -y install cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl net-snmp net-snmp-libs openldap openssl xz-libs
sudo yum install -y openldap openldap-clients openldap-servers
sudo mkdir -p /data
sudo chown mongod:mongod /data
sudo systemctl start mongodb-mms-automation-agent.service
sudo systemctl enable mongodb-mms-automation-agent.service
echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg 
export pubdns=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
sudo hostnamectl set-hostname $pubdns
sudo reboot
