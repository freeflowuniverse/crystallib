set -ex

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt-get update
apt-get install -y build-essential curl gettext git openssh-server s6 \
    sqlite tzdata gnupg libsodium-dev nodejs npm pkg-config

#here we install GOLANG in this package, this should be a separate one
curl -L https://dl.google.com/go/go${gover}.linux-amd64.tar.gz > /tmp/go${gover}.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go${gover}.linux-amd64.tar.gz
mkdir -p /gopath


export PATH=/usr/local/go/bin:`env | grep PATH | cut -d= -f2`

go version

git clone https://github.com/freeflowuniverse/freeflow_git.git gitea_src
cd gitea_src
make clean-all build

cp gitea ${binpath}/

echo "GITEA INSTALLED SUCCESFULLY"
