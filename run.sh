#!/bin/bash

# Check if the loxberry folder exists,
# otherwise clone from GIT (first run)
if [ ! -d "/opt/loxberry/system" ]; then
    cd /opt && \
    git clone https://github.com/mschlenstedt/Loxberry.git --branch master --single-branch loxberry
fi

# Creating dummy file to avoid filesystem
# resize by loxberryinit.sh
touch /boot/rootfsresized

# Setting permissions on folders    
chown -R loxberry.loxberry /opt/loxberry
chmod 600 /opt/loxberry/system/network/interfaces
chmod 600 /opt/loxberry/config/system/*
chown root.root /opt/loxberry/config/system/logrotate

# Apache configuration
echo "Linking /etc/apache2 to /opt/loxberry/system/apache2"
rm -rf /etc/apache2
ln -s /opt/loxberry/system/apache2 /etc/apache2

# Logrotate
echo "Linking /etc/logrotate.d/loxberry to /opt/loxberry/config/system/logrotate"
ln -s /opt/loxberry/config/system/logrotate /etc/logrotate.d/loxberry

# Samba settings
echo "Linking /etc/samba to /opt/loxberry/system/samba"
rm -rf /etc/samba
ln -s /opt/loxberry/system/samba /etc/samba

# VSFTPd
echo "Linking /etc/vsftpd.conf to /opt/loxberry/system/vsftpd/vsftpd.conf"
rm -rf /etc/vsftpd.conf
ln -s /opt/loxberry/system/vsftpd/vsftpd.conf /etc/vsftpd.conf

# SSMTP
echo "Linking /etc/ssmtp to /opt/loxberry/system/ssmtp"
rm -rf /etc/ssmtp
ln -s /opt/loxberry/system/ssmtp /etc/ssmtp

# Start loxberryinit.sh script
./opt/loxberry/sbin/loxberryinit.sh

# Start Apache2
/usr/sbin/apache2ctl -D FOREGROUND
