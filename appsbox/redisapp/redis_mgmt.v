module redisapp

import os
import freeflowuniverse.crystallib.appsbox
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.process
import time

[heap]
pub struct RedisApp {
pub mut:
	appconfig appsbox.AppConfig
}

pub struct RedisAppArgs {
	name string = 'default'
	port int    = 6666
}

// get a redis app based on port & name, are optional both
// default is name:default port:6666
pub fn get(args RedisAppArgs) RedisApp {
	mut factory := appsbox.get()
	// for item in factory.apps{
	// 	if item.appconfig.tcpports == [args.port] && item.appconfig.name == args.name  && item.appconfig.category == "redis"{
	// 		return item
	// 	}
	// }
	mut i := appsbox.AppConfig{
		name: args.name
		category: 'redis'
		tcpports: [args.port]
	}
	mut myapp := RedisApp{
		appconfig: i
	}
	factory.apps << myapp
	return myapp
}

pub fn (mut myapp RedisApp) start() ? {
	mut factory := appsbox.get()
	mut alive := myapp.check()?
	if alive {
		// println(" - REDIS IS ALREADY RUNNING")
		return
	}
	myapp.install(false)?

	// mut bin_path := appsbox.get().bin_path
	mut tcpport := myapp.appconfig.tcpports[0]

	process.execute_job(cmd: 'rm -f /tmp/redis_${tcpport}.sock')? // dont throw error
	mut var_path := '$factory.var_path/redis/$tcpport'

	cmd := '$var_path/redis_start'
	process.execute_job(cmd: cmd)?
	time.sleep(500000000) // 0.5 sec
	alive = myapp.check()?
	if !alive {
		return error('Could not start redis. Check failed.')
	}
}

pub fn (mut myapp RedisApp) stop() ? {
	mut bin_path := appsbox.get().bin_path
	mut tcpport := myapp.appconfig.tcpports[0]
	cmd := '$bin_path/redis-cli -p $tcpport SHUTDOWN'
	process.execute_job(cmd: cmd)?
}

pub fn (mut myapp RedisApp) install(reset bool) ? {
	// REMARK: cannot use node construct because needs redis server, chicken and the egg
	mut factory := appsbox.get()

	myapp.appconfig.bins = ['redis-server', 'redis-cli']

	// check app is installed, if yes don't need to do anything
	if reset || !myapp.appconfig.exists() {
		myapp.build()?
	}

	mut tcpport := myapp.appconfig.tcpports[0]
	mut var_path := '$factory.var_path/redis/$tcpport'
	if !os.exists(var_path) {
		os.mkdir_all(var_path)?
	}
	mut redis_conf := $tmpl('redis.conf')
	os.write_file('$var_path/redis.conf', redis_conf)?
	os.write_file('$var_path/redis_start', '$factory.bin_path/redis-server $var_path/redis.conf')?
	process.execute_job(cmd: 'chmod 770 $var_path/redis_start')?
}

pub fn (mut myapp RedisApp) build() ? {
	mut factory := appsbox.get()
	mut bin_path := factory.bin_path
	mut cmd := $tmpl('redis_build.sh')
	// mut tmpdir:="/tmp/redis"
	process.execute_job(cmd: cmd)?
}

pub fn (mut myapp RedisApp) check() ?bool {
	mut rediscl := myapp.client() or { return false }
	result := rediscl.ping()?
	if result == 'PONG' {
		return true
	}
	return false
}

pub fn (mut myapp RedisApp) client() ?&redisclient.Redis {
	panic('redis app, should not get here for now')
	mut tcpport := myapp.appconfig.tcpports[0]
	return redisclient.get('/tmp/redis_${tcpport}.sock')
	// return redisclient.get("127.0.0.1:${tcpport}")
}

pub fn client_local_get() ?&redisclient.Redis {
	mut app := get(port: 7777)
	app.start()?
	return app.client()
}
