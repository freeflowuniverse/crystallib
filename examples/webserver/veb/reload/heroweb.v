module main

import freeflowuniverse.crystallib.webserver.heroweb


fn main() {
	heroweb.example() or {
		println("Error: ${err}")
		exit(1)
	}
}