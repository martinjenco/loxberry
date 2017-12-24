FROM resin/rpi-raspbian:jessie

LABEL maintainer="Michael Miklis / <info@michaelmiklis.de>"

#RUN [ "cross-build-start" ]

ENV  DEBIAN_FRONTEND noninteractive

# Install Loxberry from mschlenstedt's repository
RUN adduser --quiet --home /opt/loxberry --no-create-home --disabled-password --gecos "User" loxberry && \
    echo "loxberry:loxberry" | chpasswd && \   
    #
    # **************************
    # Edit /etc/visudoers
    # **************************
    echo "loxberry ALL = NOPASSWD: /usr/sbin/ntpdate" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /bin/date" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /sbin/iwlist" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /usr/bin/lshw" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /sbin/poweroff" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /sbin/reboot" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /usr/bin/apt-get" >> /etc/sudoers && \
    echo "loxberry ALL = NOPASSWD: /usr/bin/dpkg" >> /etc/sudoers && \
    #
    # **************************
    # Add RaspberryPi repository for apt
    # **************************
    rm /etc/apt/sources.list.d/raspi.list && \
    echo "deb http://archive.raspberrypi.org/debian/ jessie main ui" >> /etc/apt/sources.list.d/raspi.list  && \
    apt-get -y update && \
    #
    # **************************
    # Install prerequisites packages
    # **************************
    curl https://raw.githubusercontent.com/mschlenstedt/Loxberry/master/packages.txt > /tmp/packages.txt && \
    apt-get install -y --no-install-recommends libdevice-serialport-perl git && \
    apt-get install -y --no-install-recommends $(awk 'p0 {print p0} {p0 = ($1 == "ii") ? $2 : ""}' /tmp/packages.txt) && \
    #
    # **************************
    # Install Perl modules
    # **************************
    export PERL_MM_USE_DEFAULT=1 && \
    cpan install File::HomeDir Config::Simple && \
    # 
    # **************************
    # Grant loxberry account permissions on files
    # **************************
    chown loxberry.loxberry /etc/timezone && \
    chown loxberry.loxberry /etc/localtime && \
    #
    # **************************
    # crontab
    # **************************
    echo "MAILTO=\"\"" >> /etc/crontab && \
    echo "#" >> /etc/crontab && \
    echo "# Loxberry" >> /etc/crontab && \
    echo "#" >> /etc/crontab && \
    echo "# m h dom mon dow user  command" >> /etc/crontab && \
    echo "*    *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.01min > /dev/null 2>&1" >> /etc/crontab && \
    echo "*/3  *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.03min > /dev/null 2>&1" >> /etc/crontab && \
    echo "*/5  *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.05min > /dev/null 2>&1" >> /etc/crontab && \
    echo "*/10 *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.10min > /dev/null 2>&1" >> /etc/crontab && \
    echo "*/15 *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.15min > /dev/null 2>&1" >> /etc/crontab && \
    echo "*/30 *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.30min > /dev/null 2>&1" >> /etc/crontab && \
    echo "13   *  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.hourly > /dev/null 2>&1" >> /etc/crontab && \
    echo "23   4  * * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.daily > /dev/null 2>&1" >> /etc/crontab && \
    echo "33   4  * * 1   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.weekly > /dev/null 2>&1" >> /etc/crontab && \
    echo "43   4  1 * *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.monthly > /dev/null 2>&1" >> /etc/crontab && \
    echo "53   4  1 1 *   loxberry        cd / && run-parts /opt/loxberry/system/cron/cron.yearly > /dev/null 2>&1" >> /etc/crontab && \
    #
    # **************************
    # Cleanup
    # **************************
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

#RUN [ "cross-build-end" ]
    
# Allow access to port 80 (http), 21 (ftp), 22 (ssh)
EXPOSE 80 21 22

# Start rpimonitord using run.sh wrapper script
ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD bash -C '/run.sh';'bash'
