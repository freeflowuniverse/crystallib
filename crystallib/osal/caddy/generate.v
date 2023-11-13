module caddy

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

// EXAMPLEs

// api.ourworld.tf {
//     reverse_proxy localhost:8000
// }

// info.ourworld.tf {
//     root * /var/www/info
//     file_server
//     encode gzip
// }

// ourworld.tf {
//     root * /var/www/info
//     file_server
//     encode gzip
// }

pub fn (mut self Caddy) generate() string {
	// TODO create the caddy file
}

// generate the file and write
pub fn (mut self Caddy) save() ! {
	c := self.generate()
	self.path.write(c)!
}
