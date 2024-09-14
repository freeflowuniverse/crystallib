#!/usr/bin/env -S v -n -cg -w -enable-globals run


import freeflowuniverse.crystallib.webserver.heroweb


fn main() {
	heroweb.example() or {
		println("Error: ${err}")
		exit(1)
	}
}