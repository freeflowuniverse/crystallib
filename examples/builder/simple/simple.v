module main

import freeflowuniverse.crystallib.builder
import os

const myexamplepath = os.dir(@FILE) + '/..'


fn do() ! {

	mut b:=builder.new()!
	mut n:=b.node_new(ipaddr:"root@195.192.213.2")!

	n.upload(myexamplepath,"/tmp/myexamplepath")!

	

}

fn main() {
	do() or { panic(err) }
}
