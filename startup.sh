#!/bin/bash


set -e

if [ -f /etc/configured ]; then
        echo 'already configured'
        postfix start 2>&1 & 
else
      #code that need to run only one time ....
        #needed for fix problem with ubuntu and cron
        update-locale 
        echo 'root:  root@example.com' >>/etc/aliases
        newaliases
        #add container Network Docker0 and container ip to postfix configuration , it will fail is custom container network
        postconf -e inet_interfaces=all
        postconf -e myorigin=/etc/mailname
        postconf -e mynetworks='127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
        #postconf -e smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination'
        #postconf -e mydomain=$HOSTNAME
        postconf -e myhostname=$HOSTNAME
        postconf -e mydestination=$HOSTNAME
     
        # to make sure nagios email permision are correct
        touch /var/mail/nagios
        chown nagios:mail /var/mail/nagios
        chmod o-r /var/mail/nagios
        chmod g+rw /var/mail/nagios
        #start postfix 
        postfix start 2>&1 & 
        date > /etc/configured
fi
