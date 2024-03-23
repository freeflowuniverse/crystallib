#!/usr/bin/env -S v -w -enable-globals run

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.installers.sysadmintools.rfs
import time

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

builder_name := 'go_builder'
bin_name := 'hello_world'

mut builder_cont := engine.bcontainer_new(name: builder_name, from: 'scratch')!

builder_mount_path := builder_cont.mount_to_path()!
osal.exec(
	cmd: 'pacstrap -c ${builder_mount_path} base bash coreutils vim curl mc unzip systemd vim sudo which openssh go'
)!
builder_cont.copy('./myapp', '/root/myapp')!
builder_cont.set_workingdir('/root/myapp')!
println('building')
builder_cont.run('go build -ldflags="-extldflags=-static" -o /usr/local/bin/hello', false)!
mut bin_cont := engine.bcontainer_new(name: bin_name, from: 'alpine')!
bin_cont.copy('${builder_mount_path}/usr/local/bin/hello', '/hello')!
mount_path := bin_cont.mount_to_path()!
println(mount_path)
bin_cont.set_entrypoint('/hello')!
bin_cont.set_cmd('/hello')!
bin_cont.commit('localhost/hello_world')!
