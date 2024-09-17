#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.webserver.heroweb


fn main() {
	heroweb.example() or {
		println("Error: ${err}")
		exit(1)
	}
}