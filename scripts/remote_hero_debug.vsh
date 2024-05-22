#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.osal
import os

mut server:=""
env := os.environ()
if 'SERVER' in env {
	server= env["SERVER"]
}

if server==""{
	println("specify server you want to debug on as e.g. export SERVER=65.21.132.119")
	exit(1)
}

mut b := builder.new()!
mut n := b.node_new(ipaddr: server)!

//osal.exec(cmd:"${os.home_dir()}/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh",stdout:true)!

n.upload(source: "/tmp/hero", dest: '/tmp/hero')!

println("execute installer")
n.exec(cmd:'
	set -ex
	# Ensure the script is run as root
	if [ "$(whoami)" != "root" ]; then
	echo "This script must be run as root or with sudo."
	exit 1
	fi

	# Check if the system is Ubuntu
	if ! grep -q "Ubuntu" /etc/os-release; then
	echo "This script is only for Ubuntu systems."
	exit 1
	fi

	# Update package list and install necessary packages
	DEBIAN_FRONTEND=noninteractive apt-get update -y
	DEBIAN_FRONTEND=noninteractive apt-get install -y rsync mc redis-server curl tmux screen net-tools git htop ca-certificates lsb-release screen sudo binutils wget

	# Enable and start Redis service
	systemctl enable redis-server
	systemctl start redis-server

	# Check if Redis is running
	if systemctl is-active --quiet redis-server; then
	echo "Redis is running."
	else
	echo "Failed to start Redis."
	exit 1
	fi

	mkdir -p /root/code/github/freeflowuniverse
	cd /root/code/github/freeflowuniverse	
	git clone git@github.com:freeflowuniverse/crystallib.git

	',stdout:true)!


