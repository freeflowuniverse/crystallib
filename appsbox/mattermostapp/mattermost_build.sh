set -ex

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt-get update
apt-get install -y tzdata
apt-get install -y  make git apt-transport-https ca-certificates curl \
    software-properties-common build-essential zip xmlsec1 jq

curl -L https://dl.google.com/go/go${gover}.linux-amd64.tar.gz > /tmp/go${gover}.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go${gover}.linux-amd64.tar.gz
mkdir -p /gopath

export PATH=/usr/local/go/bin:`env | grep PATH | cut -d= -f2`

git clone https://github.com/freeflowuniverse/freeflow_teams_frontend.git
git clone https://github.com/freeflowuniverse/freeflow_teams_backend.git

apt install -y nodejs npm

mkdir -p freeflow_teams_frontend/dist
cd freeflow_teams_backend && ln -nfs ../freeflow_teams_frontend/dist client
cd ../freeflow_teams_frontend && make build
cd ../freeflow_teams_backend &&  make build && make package

mkdir -p ${varpath}
tar -xf dist/mattermost-team-linux-amd64.tar.gz -C ${varpath}

echo "MATTERMOST INSTALLED SUCCESFULLY"
