module main

import freeflowuniverse.crystallib.osal.lima

fn do() ! {
	mut n := lima.vm_list()!
	println(n)
	lima.vm_new(reset:true)!

	// lima.vm_delete_all()!
}

fn main() {
	do() or { panic(err) }
}
