<h1>Hero Webserver</h2>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Local Deployment Script Script](#local-deployment-script-script)
  - [Prerequisites](#prerequisites)

---

## Introduction

This contains the Hero Webserver code.

## Local Deployment Script Script

We provide a script that deploys Hero, Vlang and Crystallib on a Ubuntu Docker conatiner, then it runs the Hero Webserver.

Make sure to follow the `Local machine` and  `Container` steps in the proper order.

### Prerequisites

- Docker Engine
- SSH key on GitHub with local paths `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`

```
# Local machine: set container
sudo docker run -it --net=host ubuntu /bin/bash

# Container: create ssh directory
mkdir -p ~/.ssh

# Local machine: transfer ssh key (from another terminal)
sudo docker ps -a # take note of the container id

id=<container_id>

# Copy key to container
sudo docker cp ~/.ssh/id_rsa ${id}:/root/.ssh/id_rsa
sudo docker cp ~/.ssh/id_rsa.pub ${id}:/root/.ssh/id_rsa.pub

# Container: Set prerequisites

apt update && apt install -y git curl nano openssh-client libsqlite3-dev
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

mkdir -p ~/code/github/freeflowuniverse
cd ~/code/github/freeflowuniverse
git clone https://github.com/freeflowuniverse/crystallib
cd crystallib

curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/install_hero.sh > /tmp/hero_install.sh
bash /tmp/hero_install.sh

curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
bash /tmp/install.sh

~/code/github/freeflowuniverse/crystallib/examples/webserver/herowebexample/heroweb-example.vsh

```
