#!/usr/bin/env -S v -w -enable-globals run

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.virt.podman

// println(osal.tcp_port_test(address:"65.21.132.119",port:22,timeout:1000))

// pub fn exec(cmd string){
// 	r:=os.exec(cmd)
// 	if res.exit_code > 0 {
// 		return error('cannot define result for link of ${path} \n${error}')
// 	}
// 	return res.output.trim_space()	

// }

name:="test"

mut engine:=podman.new(reset:false)!

println(engine.bcontainers()!)

mut c:=engine.bcontainer_new(name:"test")!

c.package_install("mc,curl")!
c.hero_install(reset:true) //build in separate container, if not done yet, then copy to this current container
c.hero_execute(heroscript:"
		!!...

		!!...

		
		")

println(c)

// println(c.inspect()!) //TODO: not working yet, please fix