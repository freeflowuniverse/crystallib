module main

import os
import time
import freeflowuniverse.crystallib.osal.zinit

fn main() {
	do() or { panic(err) }
}

fn do() ! {
	zinit.destroy()!
	mut z := zinit.new()!

	// name      string            [required]
	// cmd       string            [required]
	// cmd_file  bool  //if we wanna force to run it as a file which is given to bash -c  (not just a cmd in zinit)
	// test      string
	// test_file bool
	// after     []string
	// env       map[string]string
	// oneshot   bool

	p := z.new(
		name: 'test'
		cmd: '/bin/bash'
	)!

	println(p)
}
