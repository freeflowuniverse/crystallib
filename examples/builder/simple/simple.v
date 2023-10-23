module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.core.pathlib
import os


const myexamplepath = os.dir(@FILE) + '/../..'

fn do1() ! {

	mut b:=builder.new()!
	mut n:=b.node_new(ipaddr:"root@195.192.213.2")!

	
	n.upload(source:myexamplepath,dest:"/tmp/myexamplepath2")!
	n.download(source:"/tmp/myexamplepath2",dest:"/tmp/myexamplepath2",delete:true)!

}

fn do2() ! {

	mut b:=builder.new()!
	mut n:=b.node_local()!

	n.upload(source:myexamplepath,dest:"/tmp/myexamplepath3",delete:true)!

	//lets now put something in examplepath3, which should be deleted
	n.file_write("/tmp/myexamplepath3/something","something")!
	r:=n.file_read("/tmp/myexamplepath3/something")!
	assert r=="something"
	

	mut p2:=pathlib.get_dir("/tmp/myexamplepath2",false)! //needs to exist, and is a dir
	mut p3:=pathlib.get_dir("/tmp/myexamplepath3",false)!
	h2:=p2.md5hex()!
	mut h3:=p3.md5hex()!
	assert !(h2==h3)

	n.upload(source:"/tmp/myexamplepath2",dest:"/tmp/myexamplepath3",delete:true)!
	//now hash should be the same
	h3=p3.md5hex()!
	assert h2==h3
	size:=p3.size_kb() or {0}
	println("size: ${size}")
	

}


fn main() {
	do1() or { panic(err) }
	do2() or { panic(err) }
}
