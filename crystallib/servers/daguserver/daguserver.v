module daguserver

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.clients.dagu as daguclient
import freeflowuniverse.crystallib.crypt.secrets

pub struct DaguServer[T] {
	base.BaseConfig[T]
}

pub struct DaguServerConfig {
pub mut:
	//the config items which are important to remember
	passwd  string @[secret ] 
	secret  string @[secret ] 
	title   string
}

@[params]
pub struct DaguServerNewArgs {
pub mut:
	instance string = "default"
	passwd  string @[secret ] 
	secret  string @[secret ] 
	title   string
	install bool
}

//configure a new server
pub fn new(args DaguServerNewArgs) !DaguServer[DaguServerConfig]{

	mut server:=DaguServer[DaguServerConfig]{}
	server.init(instance:args.instance)!

	mut cfg:=DaguServerConfig{
		passwd:args.passwd
		secret:args.secret
		title:args.title
	}

	if cfg.title==""{
		cfg.title="My Hero DAG"
	}

	if cfg.passwd==""{
		cfg.passwd=secrets.hex_secret()!
	}
	if cfg.secret==""{
		cfg.secret=secrets.openssl_hex_secret()!
		
	}	
	server.config_set(myconfig)!

	if args.install{
		daguinstaller.install(
			start:true
			passwd:cfg.passwd
			secret:cfg.secret
			title:cfg.title
		)!
	}

}

pub fn get(name string) !DaguServer[DaguServerConfig]{
	mut server:=DaguServer[DaguServerConfig]{}
	server.init(instance:args.instance)!
	return server
}


pub fn (mut server DaguServer) client(name string) !daguclient.DAGU{

	mut servercfg:= server.config()!

	mut cfg:=daguclient.DaguClientConfig{
			url:"http://localhost:3333/api/v1/"
			username:"admin"
			password:servercfg.password
			apisecret:servercfg.secret
		}	

	mut cl:=daguclient.get(instance:name,config:cfg)!

	return cl

}