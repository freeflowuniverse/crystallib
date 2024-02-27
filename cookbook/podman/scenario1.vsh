#!/usr/bin/env -S v -w -enable-globals run

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.virt.podman

// println(osal.tcp_port_test(address:"65.21.132.119",port:22,timeout:1000))

mut engine := podman.new(reset: false)!

container_name := 'testarch'

mut cont := engine.bcontainer_new(name: container_name, from: 'scratch')!
mount_path := cont.mount_to_path()!
osal.exec(
	cmd: 'pacstrap -c ${mount_path} base bash coreutils vim curl mc unzip systemd vim sudo which openssh'
)!
// install v and crystallib
cont.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh -o /tmp/install.sh',
	false)!
cont.run('bash /tmp/install.sh', false)!
// install hero
cont.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh -o installer_hero.sh',
	false)!
cont.run('bash -c "redis-server --daemonize yes && bash installer_hero.sh"', false)!
cont.set_entrypoint("redis-server")!
cont.commit('localhost/myarch')!
// podman run --rm -it localhost/myarch bash
