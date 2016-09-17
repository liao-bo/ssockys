#!/bin/sh
DIR=$(cd `dirname $0`; pwd)
if [ $1 ]; then
	PASSWORD=$1
else 
	PASSWORD=$RANDOM
fi

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

delete_docker() {
	if sudo docker ps -a|grep "$1"; then
		DOCKER_ID=`sudo docker ps -a|grep "$1"|awk -F ' ' '{print $1}'`
		sudo docker stop $DOCKER_ID > /dev/null 2>&1 && sudo docker rm $DOCKER_ID > /dev/null 2>&1
		echo "delete $DOCKER_ID"
	fi
}

#install docker package
if ! command_exists docker; then
    wget https://get.docker.com/ -O /root/get_docker.sh &&sudo sh /root/get_docker.sh
fi

#delete old docker
delete_docker yanheven/ssocks
delete_docker siomiz/softethervpn

#install docker
sudo docker run -p 8888:8388 --name ssokys yanheven/ssocks nohup python shadowsocks-2.9.0/shadowsocks/server.py -k $PASSWORD &
sudo docker run -d -p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp --name l2tp -e PSK=custom -e USERNAME=custom -e PASSWORD=$PASSWORD siomiz/softethervpn
sudo cp $DIR/chap-secrets.txt /root/chap-secrets
sudo docker run -d --privileged -p 1723:1723 --name pptp --net="host"  -v /root/chap-secrets:/etc/ppp/chap-secrets mobtitude/vpn-pptp

sleep 10
nc -vz 127.0.0.1 8888 >/dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "ssocks deployment failed"
else 
	echo "ssocks deployment success"
fi

nc -vz 127.0.0.1 1723 >/dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "pptp deployment failed"
else 
	echo "pptp deployment success"
fi

nc -vz 127.0.0.1 1701 >/dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "l2tp deployment failed"
else 
	nc -uz 127.0.0.1 500 4500 >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "l2tp deployment failed"
	else
		echo "l2tp deployment success"
	fi
fi

echo "password is $PASSWORD"
