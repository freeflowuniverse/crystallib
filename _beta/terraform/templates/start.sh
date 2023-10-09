set -ex
apt update && apt upgrade -y && apt install mc curl git tmux pen htop sudo net-tools screen -y
# yes | unminimize
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh > /tmp/install.sh
#make sure to add your own email
git config --global user.email '${var.emailaddr}'
#do ipv6 from 8000 to 8080 and 8001 to 9998, the local ones are ipv4
pen -d :::8000 127.0.0.1:8080
pen -d :::8001 127.0.0.1:9998
echo ${var.secret} > /tmp/secret
echo ${var.emailaddr} > /tmp/emailaddr
# apt-get autoremove && apt-get clean
# bash /tmp/install.sh,
# bash /tmp/scripts/install_docker.sh
# bash /tmp/scripts/install_codeserver.sh
# bash /tmp/scripts/install_chroot.sh
