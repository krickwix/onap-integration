#!/bin/bash -ex

sudo rm -rf ~/pnda
sudo yum -y install git
git clone https://github.com/pndaproject/pnda ~/pnda
sudo yum -y remove git
cd ~/pnda/mirror
sudo ./create_mirror_rpm.sh && \
sudo ./create_mirror_misc.sh && \
sudo ./create_mirror_hdp.sh && \
sudo ./create_mirror_python.sh && \
sudo ./create_mirror_apps.sh
cd ~/pnda/build
host_line="127.0.1.1 $(hostname)"
echo $host_line | sudo tee -a /etc/hosts
sudo ./install-build-tools.sh
. set-pnda-env.sh
./build-pnda.sh BRANCH develop
sudo mkdir /srv/pnda_repo && \
sudo cp -av ~/pnda/mirror/mirror-dist/* /srv/pnda_repo && \
sudo cp -av ~/pnda/build/pnda-dist/* /srv/pnda_repo && \
sudo yum -y install docker && \
sudo docker run --rm -v /srv/pnda_repo:/usr/local/apache2/htdocs/ -d -p 8080:80 httpd:alpine
