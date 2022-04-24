module redisapp

import os
import builder
import appsbox
import redisclient

[heap]
pub struct RedisApp {
pub mut:
	name    	string = "default"
	instance 	appsbox.AppInstance
}

pub struct RedisAppArgs{
	name string = "default"
	port int = 6666
	
}

//get a redis app based on port & name, are optional both
// default is name:default port:6666
pub fn get(args RedisAppArgs) appsbox.App{
	mut factory := appsbox.get()
	for item in factory.apps{
		if item.instance.tcpports == [args.port] && item.instance.name == args.name {
			return item
		}
	}
	mut i := appsbox.AppInstance{
			name:args.name
			tcpports:[args.port]
		}
	mut myapp := RedisApp{
			name:args.name,
			instance:i
		}
	factory.apps << myapp
	return myapp
}

pub fn (mut myapp RedisApp) start() ?{
	mut factory := appsbox.get()
	myapp.install(false)?
	mut bin_path := appsbox.get().bin_path
	mut n := builder.node_local()?
	mut tcpport := myapp.instance.tcpports[0]
	mut var_path := "${factory.var_path}/redis/$tcpport"
	cmd := "${var_path}/redis_start"
	n.exec(cmd:cmd, reset:true, description:"start redis",stdout:true)?	
	alive := myapp.check()?
	if ! alive{
		return error("Could not start redis. Check failed.")
	}
}

pub fn (mut myapp RedisApp) stop() ?{
	mut bin_path := appsbox.get().bin_path
	mut n := builder.node_local()?
	mut tcpport := myapp.instance.tcpports[0]
	cmd := "${bin_path}/redis-cli -p $tcpport SHUTDOWN"
	n.exec(cmd:cmd, reset:true, description:"stop redis",stdout:true)?	
}

pub fn (mut myapp RedisApp) install(reset bool)?{
	mut factory := appsbox.get()

	mut n := builder.node_local()?
	myapp.instance.bins = ["redis-server","redis-cli"]

	//check app is installed, if yes don't need to do anything
	if reset || ! myapp.instance.exists(){
		myapp.build()?
	}

	mut tcpport := myapp.instance.tcpports[0]
	mut var_path := "${factory.var_path}/redis/$tcpport"
	if ! os.exists(var_path){
		os.mkdir_all(var_path)?
	}
	mut redis_conf := $tmpl("redis.conf")	
	n.executor.file_write("${var_path}/redis.conf",redis_conf)?
	n.executor.file_write("${var_path}/redis_start","${factory.bin_path}/redis-server ${var_path}/redis.conf")?
	n.executor.exec_silent("chmod 770 ${var_path}/redis_start")?
}

pub fn (mut myapp RedisApp) build()?{
	mut factory := appsbox.get()
	mut n := builder.node_local()?
	mut bin_path := factory.bin_path
	mut cmd := $tmpl("redis_build.sh")
	mut tmpdir:="/tmp/redis"
	n.exec(cmd:cmd, reset:true, description:"install redis ; echo ok",stdout:true, tmpdir:tmpdir)?
}

pub fn (mut myapp RedisApp) check()?bool{
	mut rediscl := myapp.client()?
	result := rediscl.ping()?	
	if result=="PONG"{
		return true
	}
	panic(result)
	return false
}

pub fn (mut myapp RedisApp) client() ?&redisclient.Redis {
	mut tcpport := myapp.instance.tcpports[0]
	return redisclient.get("/tmp/redis_${tcpport}.sock")
}