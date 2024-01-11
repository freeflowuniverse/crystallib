module redis

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.ui.console
import os

[heap]
pub struct RedisInstaller {
pub mut:
	name string
	port int
	datadir string
}

[params]
pub struct RedisInstallerArgs {
pub mut:
	name string = "default"
	port int = 6379
	datadir string
	start bool = true	
}

pub fn new(args_ RedisInstallerArgs) !RedisInstaller {
	mut args:=args_
	if args.datadir==""{
		args.datadir="${os.home_dir()}/hero/var/redis/${args.name}"
	}
	osal.execute_silent('mkdir -p ${args.datadir}')!
	mut r:= RedisInstaller{
		name:args.name
		port:args.port
		datadir:args.datadir
	}
	if args.start{
		r.start()!
	}
	return r
}

fn (self RedisInstaller) configfilepath() string {
	return "${self.datadir}/redis.conf"
}

fn (self RedisInstaller) configdo() ! {
	c:=$tmpl("template/redis_config.conf")
	pathlib.template_write(c, self.configfilepath(), true)!
}


pub fn (self RedisInstaller) start() ! {

	self.configdo()!
	name:="redis_${self.name}"

	mut scr:=screen.new(reset:false)!

	if scr.exists(name){
		console.print_header('redis was already running')
		return //means its working, need better check
	}

	mut s:=scr.add(name:name)!

	cmd2:="redis-server ${self.configfilepath()}"

	s.cmd_send(cmd2)!

	console.print_header('redis is running')

	res:=os.execute("redis-cli -c ping")
	if res.exit_code>0{
		return error("Redis did not install propertly could not do:'redis-cli -c ping'\n${res.output}")
	}
	

	// println(scr)
		
}

// pub fn (m RedisInstaller) stop() ! {
// 	osal.execute('')!
// }
