#! /bin/bash -e

set -x

D=$(pwd)

mkdir /root/ocdb
cd /root/ocdb

curl -sL https://deb.nodesource.com/setup | sudo bash -
apt-get -y install nodejs wget apg netcat git openssl

git clone https://github.com/fraunhoferfokus/ocdb /root/ocdb

npm install

mkdir -p db/mongodb/bin
wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.6.tgz -P /tmp/
tar -xvf /tmp/mongodb-linux-x86_64-2.6.6.tgz --strip-components 2 -C db/mongodb/bin mongodb-linux-x86_64-2.6.6/bin
rm /tmp/mongodb-linux-x86_64-2.6.6.tgz

mv $D/boot.sh /root/ocdb/
mv $D/rc.local /etc/

