#! /bin/bash -e

set -x

D=$(pwd)

curl -sSL https://get.docker.com/ubuntu/ | bash

docker pull fic2/ppnet:latest

mv $D/ppnet.conf /etc/init/
sync