#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.webserver.heroweb
import os

fn main() {


	os.chdir('${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb') or {
		println('Error changing directory: ${err}')
		exit(1)
	}


	heroweb.example() or {
		println("Error: ${err}")
		exit(1)
	}
}