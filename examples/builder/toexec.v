module main

import freeflowuniverse.crystallib.osal

fn do() ! {
	print("something")
	// if osal.is_osx() {
	// 	println('IS OSX')
	// }

	// mut job2 := osal.exec(cmd: 'ls /')!
	// println(job2)

}

fn main() {
	do() or { panic(err) }
}
