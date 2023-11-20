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

// pub fn (mut self Caddy) generate() string {
// 	return self.sites.map(generate_site(it)).join('\n')

// 	// TODO create the caddy file
// }

// // generates config for site in caddyfile
// pub fn (mut self Caddy) generate_site(site Site) string {
// 	mut config := '
// 	for domain in site.domain {
// 		'${domain.domain}:${domain.port}
// 			root * sites
// 			fileserver
// 		'
// 	}
// }

// // generate the file and write
// pub fn (mut self Caddy) save() ! {
// 	c := self.generate()
// 	self.path.write(c)!
// }
