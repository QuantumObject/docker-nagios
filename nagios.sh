#!/bin/bash
### In nagios.sh (make sure this file is chmod +x):
# `chpst -u root` runs the given command as the user `xxxxx`.
# If you omit that part, the command will be run as root.

sv -w4 check apache2

exec chpst -u root /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg 2>&1
