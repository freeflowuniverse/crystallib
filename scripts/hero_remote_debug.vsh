#!/usr/bin/env v -w -enable-globals run

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

// mut b := builder.new()!
// mut n := b.node_new(ipaddr: server)!

osal.exec(cmd:"${os.home_dir()}/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh",stdout:true)!

// n.upload(source: "/tmp/hero", dest: '/tmp/hero')!

// println("execute installer")
// n.exec(cmd:"
// 	cd /tmp
// 	chmod +x hero
// 	hero --hero -r
// 	",stdout:true)!


