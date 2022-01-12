module docker0

import rand

pub const (
	bootfile = '#!/usr/bin/dumb-init /bin/sh
set -ex

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N "" -t dsa
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

mkdir -p /root/.ssh/
chmod 700 /root/.ssh

if [ ! -f "/root/.ssh/authorized_keys" ]; then
#ln -s /myhost/authorized_keys /root/.ssh/authorized_keys
	touch /root/.ssh/authorized_keys
fi

chmod 600 /root/.ssh/authorized_keys
passwd -u root || true  #to get pam to work


#no -D because then goes to background
/usr/sbin/sshd

# @if redis_enable {
# redis-server /etc/redis.conf  --daemonize yes
# }


sh
'

	dockerfile = '# FROM alpine:3.13
FROM \$base
RUN rm  -rf /tmp/* /var/cache/apk/*
RUN apk add --no-cache redis && apk add --no-cache dumb-init 
RUN apk add --no-cache curl libssh2

RUN echo "nameserver 8.8.8.8" > "/etc/resolv.conf"

# add openssh and clean
RUN apk add --no-cache openssh && rm  -rf /tmp/* /var/cache/apk/*

# add entrypoint script
ADD boot.sh /usr/local/bin

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
RUN chmod 770 /usr/local/bin/boot.sh

RUN apk add --no-cache mc htop rsync

# @if redis_enable {
# RUN apk add --no-cache redis
# EXPOSE 6379
# }

EXPOSE 22

RUN echo "THREEFOLD BASE DEV ENV WELCOMES YOU" > /etc/motd

# ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/usr/local/bin/boot.sh"]
'

	pubkey  = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+yekqnDVUHm3eRQcfdDMWAYF6uxFQlzvRIimv7IXh2yhU8TD/9gpq9arcfsl+BJz7GPA+pvlobtVcdDvfr4Z9WhiwpAun4b5As24MoZvMNscApuc4HzIDdNTSe8DeCIpA/lfrIuwuSFz9vqtYrk126udyGOfeDicl5pwbXknc6S8uDy2uJDrEsiGnhCwVeQp3p/taaF25pMYROOIJBYXraK7+qQePX/fd7pyg+jrT6Rl+b4SXMLlSqEfWpW7DQOjqqgJARw7PjONE1CfvRiqdcZu24vm7qELjgw3roonB8trGzj7vAVulVjtWzJChISiLJdT7LYZBJEkNeNcHY49B4My0TUnlb3Ik0hiF8AaKFCvdxMMVVaQtSi1Lys3YPZMp90TMVm+Kd906MVYw4fzWPAJL0SQLtfm2YpWvEJpka/WoVE0E/SuyaYofxVC5Vmff793It30YAVR1nriiHhjG54D9zGTiz7+Lzt9dORnIHYnBTfbGElgd9SRQVJP3JFU='
	privkey = '-----BEGIN OPENSSH PRIVATE KEY-----
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
UGXNywm1Qpb3nHAAAACmhhbWR5QG15dGg=
-----END OPENSSH PRIVATE KEY-----'
)

// build ssh enabled alpine docker image
// has default ssh key in there
pub fn (mut e DockerEngine) build(force bool) ?DockerImage {
	mut found := true

	if force {
		found = false
	}

	e.image_get('threefold:latest') or { found = false }

	if !found {
		mut dest := '/tmp/$rand.uuid_v4()'
		println('Creating temp dir $dest')
		e.node.executor.exec('mkdir $dest') ?

		base := 'alpine:3.13'
		redis_enable := false

		df := docker.dockerfile.replace('\$base', base).replace('redis_enable', '$redis_enable')
		e.node.executor.exec("echo '$df' > $dest/dockerfile") ?
		e.node.executor.exec("echo '$docker.bootfile' > $dest/boot.sh") ?
		println('Building threefold image at $dest/dockerfile')
		e.node.executor.exec('cd $dest && docker build -t threefold .') or { panic(err) }
	}

	return e.image_get('threefold:latest')
}
