import freeflowuniverse.crystallib.osal.docker

fn main() {

  mut engine := docker.new(prefix: "", localonly: true)!

  mut r := engine.recipe_new(name: 'dev_tools', platform: .ubuntu)

  r.add_from(image: 'ubuntu', tag: 'latest')!

  r.add_run(cmd: 'apt update -y 
  apt install -y git vim wget openssh-server')!

  r.add_zinit()!

  r.add_zinit_cmd(name: "sshd", exec: "/usr/bin/sshd -D")!

	r.add_zinit_cmd(name: "sshkey", exec:'if [ ! -z "\$SSH_KEY" ]; then
		mkdir -p /var/run/sshd
		mkdir -p /root/.ssh
		touch /root/.ssh/authorized_keys
		
		chmod 700 /root/.ssh
		chmod 600 /root/.ssh/authorized_keys

		echo "\$SSH_KEY" >> /root/.ssh/authorized_keys
fi')!
  r.build(true)!
}