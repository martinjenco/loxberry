# docker-rpi-loxberry

Running Loxberry 1.0 inside a docker container. This container supports systemd. Therefore all services that are regis
terd with systemd will be automatically started if the container starts.
For systemd to work, the container must run in privileged mode (`--cap-add SYS_ADMIN`) and `/sys/fs/cgroup` needs to be mounted as readonly. I tested the container only on a RasberryPi based on Raspbian Stretch. Other Debian-based platforms should work when used as docker host OS.


## Limitations
The following limitations exists because Loxberry isn't really build for running inside a docker container:
- No shutdown / reboot support (use `docker stop` and `docker start` instead)
- Network configuration - to configure IP, hostname, etc. use the relevant docker run parameters (`--net`, `--ip`, `--hostname`)
- Complex Plugins such as Unifi Controller, etc. may not work (if you're running docker - run those services as separa
te containers)


## Known-Issues:
The following known-issues exists in this release:
- Long build time during hundereds of packets
- No volumes - all data is stored inside the container

## Examples
Some examples to launch the Loxberry docker container:

### Run container without access to Raspberry Pi GPIO PINs         
`docker run --name="rpi-loxberry" --cap-add SYS_ADMIN --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --restart="unless-stopped" --net=192.168.1.0 --ip=192.168.1.100 --hostname="loxberry.domain.local" --detach=true -p=80:80 -p=21:21 -p=22:22 -p=137:137/udp -p=138:138/udp -p=139:139 -p=445:445 michaelmiklis/rpi-loxberry:latest`

### Run container with access to Raspberry Pi GPIO PINs          
`docker run --name="rpi-loxberry" --cap-add SYS_ADMIN --cap-add SYS_RAWIO --device /dev/mem --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --restart="unless-stopped" --net=192.168.1.0 --ip=192.168.1.100 --hostname="loxberry.domain.local" --detach=true -p=80:80 -p=21:21 -p=22:22 -p=137:137/udp -p=138:138/udp -p=139:139 -p=445:445 michaelmiklis/rpi-loxberry:latest`


