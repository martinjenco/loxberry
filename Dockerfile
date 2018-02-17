FROM resin/rpi-raspbian:stretch

LABEL maintainer="Michael Miklis / <info@michaelmiklis.de>"

#RUN [ "cross-build-start" ]

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV init /lib/systemd/systemd

RUN echo "start" && \
    # **************************
    # Setup systemd
    # **************************
    cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/*  && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*  && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*  && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/*  && \
    rm -f /lib/systemd/system/plymouth*  && \
    rm -f /lib/systemd/system/systemd-update-utmp* && \
    systemctl set-default multi-user.target && \
    #
    #
    # **************************
    # Create gpio group
    # **************************
    groupadd -g 997 gpio && \
    #
    # **************************
    # Create user and set passwords
    # **************************
    adduser --quiet --home /opt/loxberry --no-create-home --disabled-password --gecos "User" loxberry && \
    echo "loxberry:loxberry" | chpasswd && \  
    echo "root:loxberry" | chpasswd && \ 
    usermod -a -G sudo,dialout,audio,tty,gpio,www-data loxberry && \
    #
    #
    # **************************
    # Grant loxberry account permissions on files
    # **************************
    chown loxberry.loxberry /etc/timezone && \
    chown loxberry.loxberry /etc/localtime && \ 
    #
    #
    # **************************
    # Add RaspberryPi repository for apt
    # **************************
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 82B129927FA3303E && \
    echo "deb http://archive.raspberrypi.org/debian/ stretch main ui" > /etc/apt/sources.list.d/raspi.list  && \
    apt-get -y update && \
    #
    #
    # **************************
    # Install git
    # **************************
    apt-get install -y --no-install-recommends git  && \
    #
    #
    # **************************
    # Clone loxberry repository
    # **************************
    git clone https://github.com/mschlenstedt/Loxberry.git --branch master --single-branch /opt/loxberry && \
    #
    #
    # **************************
    # Setting platform
    # **************************
    echo "raspberry" > /opt/loxberry/config/system/is_raspberry.cfg && \
    echo "Docker-Raspberry" > /opt/loxberry/config/system/is_raspdocker.cfg && \
    #
    #
    # **************************
    # Set permissions
    # **************************
    chown -R loxberry.loxberry /opt/loxberry && \
    ln -s /opt/loxberry/system/sudoers/lbdefaults /etc/sudoers.d/lbdefaults && \
    chmod 555 /opt/loxberry/system/sudoers && \
    chown root:root /opt/loxberry/system/sudoers/lbdefaults && \
    chmod 664 /opt/loxberry/system/sudoers/lbdefaults && \
    #
    #
    # **************************
    # Install packages
    # **************************
    apt-get install -y --no-install-recommends perl libdevice-serialport-perl libio-socket-ssl-perl libwww-perl libconfig-simple-perl libfile-homedir-perl && \
    #
    #
    # **************************
    # Install packages as loxberry user
    # **************************
    su -c "/opt/loxberry/sbin/installpackages.pl --file /opt/loxberry/packages.txt" loxberry && \
    #
    #
    # **************************
    # Setting samba password
    # **************************
    (echo loxberry; echo loxberry) | smbpasswd -s -a loxberry && \ 
    #
    #
    # **************************
    # Setting environment variables
    # **************************
    /opt/loxberry/sbin/setenvironment.sh && \
    /bin/bash -c "source /etc/environment"  && \
    /bin/bash -c "source /opt/loxberry/system/apache2/envvars" && \
    /bin/bash -c "source /etc/php/7.0/apache2/conf.d/20-loxberry.ini" && \
    su -c "/opt/loxberry/bin/createconfig.pl" loxberry && \
    /opt/loxberry/sbin/resetpermissions.sh  && \
    #
    #
    # **************************
    # Apache2 / lighttpd
    # **************************
    update-rc.d -f lighttpd remove  && \
    systemctl disable lighttpd  && \
    update-rc.d apache2 defaults  && \
    systemctl enable apache2  && \
    killall lighttpd || true  && \
    #
    #
    # **************************
    # PAM
    # **************************
    sed -i 's/obscure sha512/sha512 minlen=4/g' /etc/pam.d/common-password && \
    #
    #
    # **************************
    # Logrotate
    # **************************
    sed -i 's/\#compress/compress/g' /etc/logrotate.conf && \
    #
    #
    # **************************
    # RSYSLOG
    # **************************
    sed -i 's/WorkDirectory \/var\/spool\/rsyslog/WorkDirectory \/tmp/g' /etc/rsyslog.conf && \
    sed -i '/*.*;auth,authpriv.none/c\*.*;auth,authpriv.none;cron,daemon.none;	-/var/log/syslog' /etc/rsyslog.test
    #
    #
    # **************************
    # Avoid filesystem resize
    # **************************
    touch /boot/rootfsresized && \
    #
    #
    # **************************
    # Cleanup
    # **************************
    rm -rf /var/cache/apt/archives/*  && \
    su -c "/opt/loxberry/sbin/createskelfolders.pl" root && \
    rm -rf /opt/loxberry/.git*  && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

#RUN [ "cross-build-end" ]

# Allow access to port 80 (http), 21 (ftp), 22 (ssh), 137 138 445 (SMB)
EXPOSE 80 21 22 137/udp 138/udp 139 445

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/lib/systemd/systemd"]

