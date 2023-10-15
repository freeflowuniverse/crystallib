module main

import freeflowuniverse.crystallib.osal

fn do() ? {
	if osal.is_osx() {
		println('IS OSX')
	}

	mut job2 := osal.exec(cmd: 'ls /')?
	println(job2)

	// wont die, the result can be found in /tmp/execscripts
	mut job := osal.exec(cmd: 'ls dsds', die: false)?
	println(job)
}

fn main() {
	do() or { panic(err) }
}
