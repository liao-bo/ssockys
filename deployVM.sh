#!/bin/sh
DIR=$(cd `dirname $0`; pwd)

command_exists() {
	command -v "$@" > /dev/null 2>&1
}


if ! command_exists docker; then
    wget https://get.docker.com/ -O /root/get_docker.sh &&sudo sh /root/get_docker.sh
fi

sudo docker run -p 8888:8388 --name ssokys yanheven/ssocks nohup python shadowsocks-2.9.0/shadowsocks/server.py -k ffffff &
telnet 127.0.0.1 8888

sudo docker run -d -p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp --name l2tp -e PSK=yanheven -e USERNAME=yanheven -e PASSWORD=eWFuaGV2 siomiz/softethervpn

sudo cp $DIR/chap-secrets.txt /root/chap-secrets
sudo docker run -d --privileged -p 1723:1723 --name pptp --net="host"  -v /root/chap-secrets:/etc/ppp/chap-secrets mobtitude/vpn-pptp


nc -vz 127.0.0.1 8888 >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "ssocks deployment failed"
else 
	echo "ssocks deployment success"
fi

nc -vz 127.0.0.1 >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "pptp deployment failed"
else 
	echo "pptp deployment success"
fi

nc -vz 127.0.0.1 1701 >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "ssocks deployment failed"
else 
	nc -uz 127.0.0.1 500 4500 >/dev/null 2>&1
	if [ $? -eq 0]; then
		echo "ssocks deployment failed"
	else
		echo "ssocks deployment success"
	fi
fi

