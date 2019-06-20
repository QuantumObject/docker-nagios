#!/bin/bash

#reason of this script is that dockerfile only execute one command at the time but we need sometimes at the moment we create 
#the docker image to run more that one software for expecified configuration like when you need mysql running to chnage or create
#database for the container ...

 useradd --system --home /usr/local/nagios -M nagios
 groupadd --system nagcmd
 usermod -a -G nagcmd nagios
 usermod -a -G nagcmd www-data
 usermod -G nagios www-data
 cd /tmp
 wget https://sourceforge.net/projects/nagios/files/nagios-4.x/nagios-4.4.3/nagios-4.4.3.tar.gz
 wget http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
 wget https://sourceforge.net/projects/nagios/files/nrpe-3.x/nrpe-3.2.1/nrpe-3.2.1.tar.gz
 tar -xvf nagios-4.4.3.tar.gz
 tar -xvf nagios-plugins-2.2.1.tar.gz
 tar -xvf nrpe-3.2.1.tar.gz

 #installing nagios
 cd /tmp/nagios-4.4.3
  ./configure --with-nagios-group=nagios --with-command-group=nagcmd --with-mail=/usr/sbin/sendmail --with-httpd_conf=/etc/apache2/conf-available
  make all
  make install
  make install-init
  make install-config
  make install-commandmode
  make install-webconf
  cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
  chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
  mkdir -p /usr/local/nagios/var/spool
  mkdir -p /usr/local/nagios/var/spool/checkresults
  chown -R nagios:nagios /usr/local/nagios/var
  /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
  ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios
  
  #installing plugins 
  cd /tmp/nagios-plugins-2.2.1/
  ./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules --enable-extra-opts
  make
  make install

  cd /tmp/nrpe-3.2.1/
  ./configure --with-nrpe-user=nagios --with-nrpe-group=nagios --with-nagios-user=nagios --with-nagios-group=nagios  --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
  make all
  make install-plugin
  
  #to fix error relate to ip address of container apache2
  echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
  ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

  
  a2enmod cgi
  htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin
  sed -i 's/#Include.*/Include conf-available\/nagios.conf/' /etc/apache2/sites-enabled/000-default.conf
  sed -i 's/\/usr\/sbin\/sendmail -s/\/usr\/sbin\/sendmail -vt/' /usr/local/nagios/etc/objects/commands.cfg
  rm -rf /tmp/* /var/tmp/* 
