module garage_s3

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.clients.httpconnection
// import os
import time

@[params]
pub struct S3Config {
pub mut:
	replication_mode    string = '3'
	metadata_dir        string = '/var/lib/garage/meta'
	data_dir            string = '/var/lib/garage/data'
	sled_cache_capacity u32    = 128 // in MB
	compression_level   u8     = 1

	rpc_secret        string
	rpc_bind_addr     string = '[::]:3901'
	rpc_bind_outgoing bool
	rpc_public_addr   string

	bootstrap_peers []string

	api_bind_addr string = '[::]:3900'
	s3_region     string = 'garage'
	root_domain   string = '.s3.garage'

	web_bind_addr   string = '[::]:3902'
	web_root_domain string = '.web.garage'

	admin_api_bind_addr string = '0.0.0.0:3903'
	admin_metrics_token string
	admin_token         string
	admin_trace_sink    string = 'http://localhost:4317'
}

// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn start(args S3Config) ! {
	install()!

	mut config_file := $tmpl('templates/garage.toml')

	console.print_header('garage start')

	name := 'garage'

	mut scr := screen.new()!

	mut s := scr.add(name: name, reset: true)!

	cmd := 'garage server'

	s.cmd_send(cmd)!

	for _ in 0 .. 50 {
		if check(args)! {
			return
		}
		time.sleep(100 * time.millisecond)
	}

	return error('garage serveer is not healthy, could not call api.')
}

pub fn stop() ! {
	console.print_header('garage stop')

	name := 'garage'

	mut scr := screen.new()!
	scr.kill(name)!
}

fn check(args S3Config) !bool {
	// TODO: implement health check
	return true
}
