module daguserver

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.crypt.secrets
import os
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.ui.console

pub struct DaguServer[T] {
	base.BaseConfig[T]
}

@[params]
pub struct Config {
pub mut:
	homedir     string
	configpath  string
	username    string
	password    string @[secret]
	secret      string @[secret]
	title       string = 'My Hero DAG'
	description string // optional
	host        string = 'localhost' // server host (default is localhost)
	port        int    = 8888 // server port (default is 8888)	
}

pub fn new(args Config) !DaguServer[Config] {
	mut c := configure('default', args)!
	return c
}

pub fn get(instance_ string) !DaguServer[Config] {
	instance := if instance_ == '' { 'default' } else { instance_ }
	mut self := DaguServer[Config]{}
	self.init('daguserver', instance, .get)!
	return self
}

// set the configuration, will make defaults for password & secret
pub fn configure(instance string, cfg_ Config) !DaguServer[Config] {
	mut cfg := cfg_
	mut self := DaguServer[Config]{}

	if cfg.title == '' {
		cfg.title = 'My Hero DAG'
	}

	if cfg.username == '' {
		cfg.username = 'admin'
	}

	dagu_secret := os.getenv('DAGU_SECRET')
	console.print_debug("dagu secret from getenv:'${dagu_secret}'")
	if cfg.password == '' {
		cfg.password = dagu_secret
	}
	if cfg.password == '' {
		cfg.password = secrets.hex_secret()!
	}

	// TODO:use DAGU_SECRET from env variables in os if not set then empty string
	if cfg.secret == '' {
		cfg.secret = secrets.openssl_hex_secret(input: dagu_secret)!
	}

	if cfg.homedir == '' {
		cfg.homedir = '${os.home_dir()}/hero/var/dagu'
	}

	if cfg.configpath == '' {
		cfg.configpath = '${os.home_dir()}/hero/cfg/dagu.yaml'
	}

	if cfg.port == 0 {
		cfg.port = 8080
	}

	self.init('daguserver', instance, .set, cfg)!

    os.mkdir_all(cfg.homedir) or {
        return error('Failed to create home directory: ${cfg.homedir} $err')
    }
	return self
}

pub struct InstallArgs {
pub mut:
	homedir    string
	configpath string
	username   string
	password   string @[secret]
	secret     string @[secret]
	title      string = 'My Hero DAG'
	reset      bool
	start      bool = true
	stop       bool
	restart    bool
	host       string = 'localhost' // server host (default is localhost)
	port       int    = 8888
}
