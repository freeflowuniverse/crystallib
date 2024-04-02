#!/usr/bin/env -S v -w -enable-globals run

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.virt.podman

// in this scenario we
// 1- build an image from scratch
// 2- get mount point of this image
// 3- pacstrap arch to that mount point
// 4- install crystallib and vlang
// 5- install hero
// 6- install rfs to back the content of the mount point to store s3 ` in this example we use a local dir just for testing`
// 7- pack the content
// 8- mounting flist to /tmp/mount_fl
//
mut engine := podman.new(reset: false)!

container_name := 'testarch'

mut cont := engine.bcontainer_new(name: container_name, from: 'scratch')!
mount_path := cont.mount_to_path()!
osal.exec(
	cmd: 'pacstrap -c ${mount_path} base bash coreutils vim curl mc unzip systemd vim sudo which openssh fuse2'
)!
// install v and crystallib
cont.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh -o /tmp/install.sh',
	false)!
cont.run('bash /tmp/install.sh', false)!
// install hero
cont.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh -o installer_hero.sh',
	false)!
cont.run('bash -c "redis-server --daemonize yes && bash installer_hero.sh"', false)!
cont.set_entrypoint('redis-server')!
cont.commit('localhost/myarch')!
// install rfs
osal.exec(
	cmd: 'curl -fsSL https://github.com/threefoldtech/rfs/releases/download/v2.0.4/rfs -o /usr/local/bin/rfs'
)!
osal.exec(cmd: 'chmod +x /usr/local/bin/rfs')!
// remove the folder if it exists
osal.exec(cmd: 'rm -fr /tmp/store1')!
osal.exec(cmd: 'mkdir -p /tmp/mount_fl /tmp/store1')!
osal.exec(
	cmd: 'rfs pack -m output.fl -s dir:///tmp/store1 ${mount_path}'
)!
println('mounting to `/tmp/mount_fl` you can check the flist mounted there now, consider doing umount after u finish')
osal.exec(cmd: 'sudo rfs mount -m output.fl /tmp/mount_fl', timeout: 90000)!
