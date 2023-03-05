module main

import os
import freeflowuniverse.crystallib.data
import time

fn do() ! {
	a := data.new_primitive([time.now(), time.now()])
	println(a)
	mut llist := [u16(18), u16(19), u16(20)]
	b := data.new_primitive(llist)
	println(b)
}

fn main() {
	do() or { panic(err) }
}
