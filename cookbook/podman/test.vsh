#!/usr/bin/env -S v -w -enable-globals run

import os
import freeflowuniverse.crystallib.osal

// println(osal.tcp_port_test(address:"65.21.132.119",port:22,timeout:1000))

// pub fn exec(cmd string){
// 	r:=os.exec(cmd)
// 	if res.exit_code > 0 {
// 		return error('cannot define result for link of ${path} \n${error}')
// 	}
// 	return res.output.trim_space()	

// }

containerid:=osal.exec(cmd:"$(buildah from docker.io/archlinux:latest)")!
println(containerid)