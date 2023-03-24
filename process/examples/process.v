module main

import freeflowuniverse.crystallib.process

fn do() ? {
	if process.is_osx() {
		println('IS OSX')
	}

	mut job2 := process.execute_job(cmd: 'ls /')?
	println(job2)

	// wont die, the result can be found in /tmp/execscripts
	mut job := process.execute_job(cmd: 'ls dsds', die: false)?
	println(job)
}

fn main() {
	do() or { panic(err) }
}
