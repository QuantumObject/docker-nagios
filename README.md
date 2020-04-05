[![Docker Build Statu](https://img.shields.io/docker/build/quantumobject/docker-nagios.svg)](https://hub.docker.com/r/quantumobject/docker-nagios/) [![Docker Automated buil](https://img.shields.io/docker/automated/quantumobject/docker-nagios.svg)](https://hub.docker.com/r/quantumobject/docker-nagios/)

# docker-nagios

Docker container for [Nagios 4.4.5][3]

"Nagios Is The Industry Standard In IT Infrastructure Monitoring. Achieve instant awareness of IT infrastructure problems, so downtime doesn't adversely affect your business.Nagios offers complete monitoring and alerting for servers, switches, applications, and services."

## Install dependencies

- [Docker][2]

To install docker in Ubuntu 18.04 use the commands:

```
$ sudo apt-get update 
$ sudo wget -qO- https://get.docker.com/ | sh
```

To install docker in other operating systems check [docker online documentation][4]

## Usage
 I used this
To run container use the command below:

```
$ docker run -d -p 25 -p 80:80 --name nagios quantumobject/docker-nagios
```

login : nagiosadmin password: admin please replace it after install.

to access the container please use :

``` I used this
$ docker exec -it container_id  /bin/bash
```

to replace password :

```
$ htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```

note: to access site is <http://server_ip:external_container_port/nagios/>

update to nrpe-4.0.0

update to nagios-plugins-2.3.3

## More Info

About Nagios [www.nagios.org][1]

To help improve this container [quantumobject/docker-nagios][5]

For additional info about us and our projects check our site [www.quantumobject.org][6]

[1]: http://www.nagios.org/
[2]: https://www.docker.com
[3]: http://www.nagios.org/download
[4]: http://docs.docker.com
[5]: https://github.com/QuantumObject/docker-nagios
[6]: https://www.quantumobject.org/
