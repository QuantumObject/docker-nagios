#!/bin/sh

exec chpst -u www-data svlogd -tt /var/log/apache2/
