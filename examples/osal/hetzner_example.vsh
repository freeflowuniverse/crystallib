#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.hetzner
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.builder

import os

//interative means will ask for login/passwd

console.print_header("Hetzner login.")


// mut session := play.session_new(
// 	context_name: "test"
// 	interactive: true
// )!
// mut cl:=hetzner.get(session:session)!

//it will ask for login/passwd and store in test context db
// mut cl:=hetzner.new()!

//can only use get once a new has been done, because that creates an account
mut cl:=hetzner.get()!

for i in 0..5{
	println("test cache, first time slow then fast")
	cl.servers_list()!
}

println(cl.servers_list()!)

mut serverinfo:= cl.server_info_get(name:"kristof2")!

println(serverinfo)

// cl.server_reset(name:"kristof2",wait:true)!

// cl.server_rescue(name:"kristof2",wait:true)!

// hetzner.crystal_install(serverinfo.server_ip)!

mut b := builder.new()!
mut n := b.node_new(ipaddr: serverinfo.server_ip)!

// n.crystal_install()!
n.hero_compile_debug()!

// mut ks:=cl.keys_get()!
// println(ks)


