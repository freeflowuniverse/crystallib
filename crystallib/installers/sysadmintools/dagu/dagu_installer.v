module dagu

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os
import time

pub const version = '1.14.2'

@[params]
pub struct InstallArgs {
pub mut:
	homedir    string
	configpath string
	username   string = "admin"
	password   string @[secret]
	secret     string @[secret]
	title      string = 'My Hero DAG'
	reset      bool
	start      bool = true
	stop 	   bool
	restart    bool
	host        string = 'localhost' // server host (default is localhost)
	port       int = 8888
}


pub fn install(args_ InstallArgs) ! {
	mut args := args_

	if !is_installed(version)! {
		args.reset = true
	}

	if args.reset {
		console.print_header('install dagu')

		mut url := ''
		if osal.is_linux_arm() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_linux_arm64.tar.gz'
		} else if osal.is_linux_intel() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_linux_amd64.tar.gz'
		} else if osal.is_osx_arm() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_darwin_arm64.tar.gz'
		} else if osal.is_osx_intel() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_darwin_amd64.tar.gz'
		} else {
			return error('unsported platform')
		}

		mut dest := osal.download(
			url: url
			minsize_kb: 9000
			expand_dir: '/tmp/dagu'
		)!

		mut binpath := dest.file_get('dagu')!
		osal.cmd_add(
			cmdname: 'dagu'
			source: binpath.path
		)!
	}

	if args.restart {
		restart(args)!
		return
	}

	if args.start {
		start(args)!
		return
	}

	if args.stop {
		stop()!
	}	


}

pub fn start(args_ InstallArgs) ! {
	mut args := args_

	if args.title == '' {
		args.title = 'HERO DAG'
	}

	if args.homedir == '' {
		args.homedir = '${os.home_dir()}/hero/var/dagu'
	}
	if args.configpath == '' {
		args.configpath = '${os.home_dir()}/hero/cfg/dagu.yaml'
	}

	if check(args)! {
		return
	}

	console.print_header('dagu start')

	//println(args)


	configure(args)!

	cmd := 'dagu server --host 0.0.0.0 --config ${args.configpath}'

	// TODO: we are not taking host & port into consideration

	// dags string // location of DAG files (default is /Users/<user>/.dagu/dags)
	// host string // server host (default is localhost)
	// port string // server port (default is 8080)
	// result := os.execute_opt('dagu start-all ${flags}')!

	mut sm := startupmanager.get()!

	sm.start(
		name: 'dagu'
		cmd: cmd
		env: {
			'HOME': '/root'
		}
	)!

	//cmd2 := 'dagu scheduler' // TODO: do we need this
	console.print_debug(cmd)

	// if true{
	// 	panic("sdsdsds dagu install")
	// }


	// time.sleep(100000000000)
	for _ in 0 .. 50 {
		if check(args)! {
			return
		}
		time.sleep(100 * time.millisecond)
	}
	return error('dagu did not install propertly, could not call api.')	

}



pub fn configure(args_ InstallArgs) ! {
	mut cfg := args_

	if cfg.password == "" || cfg.secret == ""{
		return error("password and secret needs to be filled in for dagu")
	}


	mut mycode := $tmpl('templates/admin.yaml')

	mut path := pathlib.get_file(path: cfg.configpath, create: true)!
	path.write(mycode)!

	console.print_debug(mycode)
	

}

// checks if a certain version or above is installed
pub fn is_installed(version string) !bool {
	res := os.execute('${osal.profile_path_source_and()} dagu version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().len > 0)
		if r.len != 1 {
			return error("couldn't parse dagu version.\n${res.output}")
		}
		if texttools.version(version) > texttools.version(r[0]) {
			return false
		}
	} else {
		return false
	}
	return true
}

pub fn check(args InstallArgs) !bool {
	// this checks health of dagu
	// curl http://localhost:3333/api/v1/s --oauth2-bearer 1234 works
	mut conn := httpconnection.new(name: 'dagu', url: 'http://127.0.0.1:${args.port}/api/v1/')!

	// console.print_debug("curl http://localhost:3333/api/v1/dags --oauth2-bearer ${secret}")
	if args.secret.len > 0 {
		conn.default_header.add(.authorization, 'Bearer ${args.secret}')
	}
	conn.default_header.add(.content_type, 'application/json')
	console.print_debug('check connection to dagu')
	r0 := conn.get(prefix: 'dags') or { return false }
	// if it gets here then is empty but server answers, the below might not work if no dags loaded

	// println(r0)
	// if true{panic("ssss")}
	// r := conn.get_json_dict(prefix: 'dags', debug: false) or {return false}
	// println(r)
	// dags := r['DAGs'] or { return false }
	// // console.print_debug(dags)
	console.print_debug('Dagu is answering.')
	return true
}


pub fn stop() ! {
	console.print_header('Dagu Stop')
	mut sm := startupmanager.get()!
	sm.stop('dagu')!
}

pub fn restart(args InstallArgs) ! {
	stop()!
	start(args)!
}



pub fn installargs(args InstallArgs) InstallArgs {
	return args	
}