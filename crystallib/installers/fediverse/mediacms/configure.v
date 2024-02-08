module mediacms

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import os

@[params]
pub struct Config {
pub mut:
	name            string = 'default'
	reset           bool
	dest            string = '/data/mediacms'
	passwd          string @[required]
	postgresql_name string = 'default'
	domain          string @[required]
	title           string
	timezone        string = 'Africa/Kinshasa'
	mail_from       string @[required]
	smtp_addr       string @[required]
	smtp_login      string @[required]
	smtp_port       int = 587
	smtp_passwd     string @[required]
}

pub fn configure(myargs Config) ! {
	checkplatform()!

	dest := myargs.dest
	if !(os.exists('${dest}')) {
		return error("can't find dest: ${dest}")
	}

	$if debug {
		console.print_header('mediacms configured properly.')
	}
}

fn checkplatform() ! {
	myplatform := osal.platform()
	if !(myplatform == .ubuntu || myplatform == .arch) {
		return error('platform not supported')
	}
}
