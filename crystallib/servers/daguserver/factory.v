module dagu

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.crypt.secrets
import freeflowuniverse.crystallib.clients.dagu as daguclient
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller

//import freeflowuniverse.crystallib.ui.console

pub struct DaguServer[T] {
	base.BaseConfig[T]
}

@[params]
pub struct Config {
pub mut:
	homedir string
	configpath string
	passwd   string @[secret] 
	secret   string @[secret]
	title    string = 'My Hero DAG'
	description string //optional
	host string = "localhost" // server host (default is localhost)
	port int = 8888 // server port (default is 8888)	
}


pub fn get(instance string) !DaguServer[Config] {
	mut self := DaguServer[Config]{}
	self.init('daguserver', instance, .get)!
	return self
}


//set the configuration, will make defaults for passwd & secret
pub fn configure(instance string, cfg_ Config) !DaguServer[Config] {


	mut cfg:=cfg_
	mut self := DaguServer[Config]{
	}

	if cfg.title == '' {
		cfg.title = 'My Hero DAG'
	}

	if cfg.passwd == '' {
		cfg.passwd = secrets.hex_secret()!
	}
	if cfg.secret == '' {
		cfg.secret = secrets.openssl_hex_secret()!
	}	

	if cfg.homedir == ""{
		cfg.homedir = '${os.home_dir()}/hero/var/dagu'
	}
		
	if cfg.configpath == ""{
		cfg.configpath = '${os.home_dir()}/hero/cfg/dagu.yaml'
	}
		
	daguinstaller.install(
		start:true
		homedir:cfg.homedir
		passwd:cfg.passwd
		secret:cfg.secret
		title :cfg.title
		)!


	self.init('daguserver', instance, .set, cfg)!

	//configure a client to the local instance
	// the name will be 'local'
	daguclient.get("local",
		url: 'http://localhost:3333/api/v1/'
		username: 'admin'
		password: cfg.passwd
		apisecret: cfg.secret	
	)!
	return self
}