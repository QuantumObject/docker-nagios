#name of container: docker-nagios
#versison of container: 0.6.2
FROM quantumobject/docker-baseimage:18.04
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

# Allow postfix to install without interaction.
RUN echo "postfix postfix/mailname string example.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q  wget \
                    build-essential \
                    apache2 \
                    apache2-utils \
                    iputils-ping \
                    php-gd \
                    libapache2-mod-php \
                    postfix \
                    libssl-dev \
                    unzip \
                    libdigest-hmac-perl \
                    libnet-snmp-perl \
                    libcrypt-des-perl \
                    mailutils \
                    snmp \
                    lm-sensors snmp-mibs-downloader \
                    dnsutils \
                    nagios-nrpe-plugin \
                    && rm -R /var/www/html \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

##startup scripts
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Get Mibs
RUN /usr/bin/download-mibs
RUN echo 'mibs +ALL' >> /etc/snmp/snmp.conf


##Adding Deamons to containers
# to add apache2 deamon to runit
RUN mkdir -p /etc/service/apache2  /var/log/apache2 ; sync
RUN mkdir /etc/service/apache2/log
COPY apache2.sh /etc/service/apache2/run
COPY apache2-log.sh /etc/service/apache2/log/run
RUN chmod +x /etc/service/apache2/run /etc/service/apache2/log/run \
    && cp /var/log/cron/config /var/log/apache2/ \
    && chown -R www-data /var/log/apache2

# to add nagios deamon to runit
RUN mkdir /etc/service/nagios /var/log/nagios ; sync
RUN mkdir /etc/service/nagios/log
COPY nagios.sh /etc/service/nagios/run
COPY nagios-log.sh /etc/service/nagios/log/run
RUN chmod +x /etc/service/nagios/run /etc/service/nagios/log/run \
    && cp /var/log/cron/config /var/log/nagios/ \
    && chown -R root /var/log/nagios

#pre-config scritp for different service that need to be run when container image is create
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf ; sync
RUN /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf


##Copy plguins installed though apt to location
RUN cp /usr/lib/nagios/plugins/check_nrpe /usr/local/nagios/libexec/ ; sync

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 80 25

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
