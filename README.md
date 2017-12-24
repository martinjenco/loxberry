# docker-rpi-loxberry

** heavy work in progess / still under development **

Loxberry inside a docker container


## Examples

To run the docker container:
docker run --volume=/opt/loxberry:/opt/loxberry -p=80:80 -p=21:21 --name="loxberry" --restart="unless-stopped" -d  michaelmiklis/rpi-loxberry:latest

### Run container with access to Raspberry Pi GPIO PINs
docker run --volume=/opt/loxberry:/opt/loxberry -p=80:80 -p=21:21 --name="loxberry" --restart="unless-stopped" --cap-add SYS_RAWIO --device /dev/mem -d  michaelmiklis/rpi-loxberry:latest
