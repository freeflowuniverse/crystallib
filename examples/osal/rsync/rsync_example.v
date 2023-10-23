module main

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.builder
import os

const myexamplepath = os.dir(@FILE) + '/../..'

fn do1() ! {

	tstdir:="/tmp/testsync"
	// source string
	// dest string
	// delete bool //do we want to delete the destination
	// ipaddr_src string //e.g. root@192.168.5.5:33 (can be without root@ or :port)
	// ipaddr_dst string
	// ignore []string //arguments to ignore e.g. ['*.pyc','*.bak']
	// ignore_default bool //if set will ignore a common set
	// stdout bool
	osal.rsync(source:myexamplepath,dest:tstdir,delete:true)!
	cmd:=osal.rsync_cmd(source:myexamplepath,dest:tstdir)!
	println(cmd)
	//"rsync -avz --no-perms   --exclude='*.pyc' --exclude='*.bak' --exclude='*dSYM' /Users/despiegk1/code/github/freeflowuniverse/crystallib/examples /tmp/testsync"
	



}

fn do2() ! {

	mut b:=builder.new()!
	mut n:=b.node_new(ipaddr:"root@195.192.213.2")!
	tstdir:="/tmp/testsync"
	n.exec("mkdir -p ${tstdir}")!

	ipaddr:="root@195.192.213.2"	
	osal.rsync(source:myexamplepath,ipaddr_dst:ipaddr,dest:tstdir,delete:true)!
	cmd:=osal.rsync_cmd(source:myexamplepath,dest:tstdir)!
	println(cmd)
	


}


fn do3() ! {

	ipaddr:="root@195.192.213.2:22"
	tstdir:="/tmp/testsync"

	osal.rsync(ipaddr_src:ipaddr,source:tstdir,dest:tstdir,delete:true)!
	cmd:=osal.rsync_cmd(source:tstdir,dest:tstdir)!
	println(cmd)
	


}


fn main() {
	do1() or { panic(err) }
	do2() or { panic(err) }
	do3() or { panic(err) }
}
