module garage_s3

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.crypt.secrets
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.clients.httpconnection
// import os
import time

@[params]
pub struct S3Config {
pub mut:
	replication_mode    string = '3'
	metadata_dir        string = '/var/garage/meta'
	data_dir            string = '/var/garage/data'
	sled_cache_capacity u32    = 128 // in MB
	compression_level   u8     = 1

	rpc_secret        string //{GARAGE.RPCSECRET}
	rpc_bind_addr     string = '[::]:3901'
	rpc_bind_outgoing bool
	rpc_public_addr   string = '127.0.0.1:3901'

	bootstrap_peers []string

	api_bind_addr string = '[::]:3900'
	s3_region     string = 'garage'
	root_domain   string = '.s3.garage'

	web_bind_addr   string = '[::]:3902'
	web_root_domain string = '.web.garage'

	admin_api_bind_addr string = '[::]:3903'
	admin_metrics_token string //{GARAGE:METRICSTOKEN}
	admin_token         string //{GARAGE:ADMINTOKEN}
	admin_trace_sink    string = 'http://localhost:4317'

	reset bool
	start bool
}

pub fn start(args_ S3Config) ! {
	mut args := args_
	mut config_file := $tmpl('templates/garage.toml')

	console.print_header('garage start')

	// create the paths
	myconfigpath_ := '${args.metadata_dir}/garage.toml'

	mut box := secrets.get()!
	config_file = box.replace(
		txt: config_file
		defaults: {
			'GARAGE.RPCSECRET':    secrets.DefaultSecretArgs{
				secret: args.rpc_secret
				cat: .openssl_hex
			}
			'GARAGE.METRICSTOKEN': secrets.DefaultSecretArgs{
				secret: args.admin_metrics_token
				cat: .openssl_base64
			}
			'GARAGE.ADMINTOKEN':   secrets.DefaultSecretArgs{
				secret: args.admin_token
				cat: .openssl_base64
			}
		}
		printsecrets: true
	)!

	mut myconfigpath := pathlib.get_file(path: myconfigpath_, create: true)!
	myconfigpath.write(config_file)!
	pathlib.get_dir(path: args.data_dir, create: true)!

	mut sm := startupmanager.get()!

	sm.start(
		name: 'garage'
		cmd: 'garage -c ${myconfigpath_} server'
	)!

	console.print_debug('garage -c ${myconfigpath_} server')

	for _ in 0 .. 50 {
		if check(args)! {
			return
		}
		time.sleep(100 * time.millisecond)
	}

	return error('garage server did not start properly.')
}

pub fn stop() ! {
	console.print_header('garage stop')
	mut sm := startupmanager.get()!
	sm.kill('garage')!
}

fn check(args S3Config) !bool {
	// TODO: implement health check
	return true
}
