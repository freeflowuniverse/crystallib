#!/bin/bash

# 1. basics
apt-get update
apt-get install -y curl sudo unzip vim

# 3. nodejs
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

apt-get update
apt-get install nodejs -y

# 4. yarn
npm install --global yarn

# 5. python
apt-get install -y python3-dev python-is-python3

# 6. common dependencies
apt-get install -y certbot nginx ffmpeg postgresql postgresql-contrib openssl g++ make redis-server git cron wget

/etc/init.d/redis-server start
/etc/init.d/postgresql start



# 7. peertube setup
useradd -m -d /var/www/peertube -s /bin/bash -p peertube peertube

# passwd peertube
chmod 755 /var/www/peertube

# 8. database
cd /var/www/peertube
sudo -u postgres createuser -P peertube # rooter
sudo -u postgres createdb -O peertube -E UTF8 -T template0 peertube_prod
sudo -u postgres psql -c "CREATE EXTENSION pg_trgm;" peertube_prod
sudo -u postgres psql -c "CREATE EXTENSION unaccent;" peertube_prod

# 9. prepare directory
VERSION=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4)
echo "Latest Peertube version is $VERSION"

cd /var/www/peertube
sudo -u peertube mkdir config storage versions
sudo -u peertube chmod 750 config

cd /var/www/peertube/versions
sudo -u peertube wget -q "https://github.com/Chocobozzz/PeerTube/releases/download/${VERSION}/peertube-${VERSION}.zip"
sudo -u peertube unzip -q peertube-${VERSION}.zip
sudo -u peertube rm peertube-${VERSION}.zip

# 10. install peertube
cd /var/www/peertube
sudo -u peertube ln -s versions/peertube-${VERSION} ./peertube-latest

cd ./peertube-latest
sudo -H -u peertube yarn install --production --pure-lockfile

# 11. configuration
cd /var/www/peertube

sudo -u peertube cp peertube-latest/config/default.yaml config/default.yaml
sudo -u peertube cp peertube-latest/config/production.yaml.example config/production.yaml

# update config/production.yaml
# openssl rand -hex 32

sudo cp /var/www/peertube/peertube-latest/support/nginx/peertube /etc/nginx/sites-available/peertube
sudo sed -i 's/${WEBSERVER_HOST}/workx0.maxux.net/g' /etc/nginx/sites-available/peertube
sudo sed -i 's/${PEERTUBE_HOST}/127.0.0.1:9000/g' /etc/nginx/sites-available/peertube

sudo ln -s /etc/nginx/sites-available/peertube /etc/nginx/sites-enabled/peertube

/etc/init.d/nginx stop
certbot certonly --standalone --post-hook "/etc/init.d/nginx start"

# 12. administator
cd /var/www/peertube/peertube-latest
NODE_CONFIG_DIR=/var/www/peertube/config NODE_ENV=production npm run reset-password -- -u root

sudo -u peertube NODE_CONFIG_DIR=/var/www/peertube/config NODE_ENV=production node dist/server


