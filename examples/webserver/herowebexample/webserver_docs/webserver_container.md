<h1> Webserver Container - Manual Deployment </h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Steps](#steps)

---

## Introduction

We provide the manual steps to deploy the Hero webserver on a Ubuntu container.

## Steps

- Run the Ubuntu container with host networking and a specific name
    ```
    sudo docker run -it --net=host --name=hero-container ubuntu:latest /bin/bash
    ```
- Create Directory .ssh in container
    ```
    mkdir -p ~/.ssh
    ```

- Copy SSH keys to container from local machine
    ```
    sudo docker cp ~/.ssh/id_rsa hero-container:/root/.ssh/id_rsa
    sudo docker cp ~/.ssh/id_rsa.pub hero-container:/root/.ssh/id_rsa.pub
    ```

- Execute all commands directly in the container

    ```
    # Install prerequisites

    apt update && apt install -y git curl nano openssh-client libsqlite3-dev

    # Set up SSH agent and add the key

    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa

    # Clone the repository and set up the environment

    mkdir -p ~/code/github/freeflowuniverse
    cd ~/code/github/freeflowuniverse
    git clone https://github.com/freeflowuniverse/crystallib
    cd crystallib

    # Download and run installation scripts

    curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/install_hero.sh > /tmp/hero_install.sh

    bash /tmp/hero_install.sh

    curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh

    bash /tmp/install.sh

    # Run the example
    ~/code/github/freeflowuniverse/crystallib/examples/webserver/herowebexample/heroweb-example.vsh
    ```