module ${args.name}

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal.zinit

@if args.build
import freeflowuniverse.crystallib.installers
import freeflowuniverse.crystallib.installers.lang.golang
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.installers.lang.python
@end

import os


// checks if a certain version or above is installed
fn installed() !bool {
	//THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
	// res := os.execute('??{osal.profile_path_source_and()} ${args.name} version')
	// if res.exit_code != 0 {
	// 	return false
	// }
	// r := res.output.split_into_lines().filter(it.trim_space().len > 0)
	// if r.len != 1 {
	// 	return error("couldn't parse ${args.name} version.\n??{res.output}")
	// }
	// if texttools.version(version) > texttools.version(r[0]) {
	// 	return false
	// }
	return true
}

fn install() ! {
	console.print_header('install ${args.name}')
	//THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
	// mut url := ''
	// if osal.is_linux_arm() {
	// 	url = 'https://github.com/${args.name}-dev/${args.name}/releases/download/v??{version}/${args.name}_??{version}_linux_arm64.tar.gz'
	// } else if osal.is_linux_intel() {
	// 	url = 'https://github.com/${args.name}-dev/${args.name}/releases/download/v??{version}/${args.name}_??{version}_linux_amd64.tar.gz'
	// } else if osal.is_osx_arm() {
	// 	url = 'https://github.com/${args.name}-dev/${args.name}/releases/download/v??{version}/${args.name}_??{version}_darwin_arm64.tar.gz'
	// } else if osal.is_osx_intel() {
	// 	url = 'https://github.com/${args.name}-dev/${args.name}/releases/download/v??{version}/${args.name}_??{version}_darwin_amd64.tar.gz'
	// } else {
	// 	return error('unsported platform')
	// }

	// mut dest := osal.download(
	// 	url: url
	// 	minsize_kb: 9000
	// 	expand_dir: '/tmp/${args.name}'
	// )!

	// //dest.moveup_single_subdir()!

	// mut binpath := dest.file_get('${args.name}')!
	// osal.cmd_add(
	// 	cmdname: '${args.name}'
	// 	source: binpath.path
	// )!
}

@if args.build
fn build() ! {

	url := 'https://github.com/threefoldtech/${args.name}'

	// make sure we install base on the node
	// if osal.platform() != .ubuntu {
	// 	return error('only support ubuntu for now')
	// }
	// golang.install()!

	// console.print_header('build ${args.name}')

	// gitpath := gittools.code_get(coderoot: '/tmp/builder', url: url, reset: true, pull: true)!

	// cmd := '
	// cd ??{gitpath}
	// source ~/.cargo/env
	// exit 1 #todo
	// '
	// osal.execute_stdout(cmd)!


}

//get the Upload List of the files
fn ulist() ?installers.UList {
	//optionally build a UList which is all paths which are result of building, is then used e.g. in upload
}


//uploads to S3 server if configured
fn upload() ! {

	// installers.upload(
	// 	cmdname: '${args.name}'
	// 	source: '??{gitpath}/target/x86_64-unknown-linux-musl/release/${args.name}'
	// )!

}

@end

@if args.startupmanager
fn startupcmd () ![]zinit.ZProcessNewArgs{
	mut res := []zinit.ZProcessNewArgs{}
	//THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
	// res << zinit.ZProcessNewArgs{
	// 	name: '${args.name}'
	// 	cmd: '${args.name} server'
	// 	env: {
	// 		'HOME': '/root'
	// 	}	
	// }

	return res
	
}
@end

//user needs to us switch to make sure we get the right object
fn configure() ! {
	mut cfg := get()! 
	//THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED
@if args.templates
	// mut mycode := ??tmpl('templates/atemplate.yaml')
	// mut path := pathlib.get_file(path: cfg.configpath, create: true)!
	// path.write(mycode)!
	// console.print_debug(mycode)
@else
@end
	//implement if steps need to be done for configuration
}




fn running() !bool {
	mut cfg := get()!

	//THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
	
	// this checks health of ${args.name}
	// curl http://localhost:3333/api/v1/s --oauth2-bearer 1234 works
	// url:='http://127.0.0.1:??{cfg.port}/api/v1'
	// mut conn := httpconnection.new(name: '${args.name}', url: url)!

	// if cfg.secret.len > 0 {
	// 	conn.default_header.add(.authorization, 'Bearer ??{cfg.secret}')
	// }
	// conn.default_header.add(.content_type, 'application/json')
	// console.print_debug("curl -X 'GET' '??{url}'/tags --oauth2-bearer ??{cfg.secret}")
	// r := conn.get_json_dict(prefix: 'tags', debug: false) or {return false}
	// println(r)
	// if true{panic("ssss")}
	// tags := r['Tags'] or { return false }
	// console.print_debug(tags)
	// console.print_debug('${args.name} is answering.')
	return true
}



fn destroy() ! {
	//THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
	// cmd:="
	// 	systemctl disable ${args.name}_scheduler.service
	// 	systemctl disable ${args.name}.service
	// 	systemctl stop ${args.name}_scheduler.service
	// 	systemctl stop ${args.name}.service

	// 	systemctl list-unit-files | grep ${args.name}

	// 	pkill -9 -f ${args.name}

	// 	ps aux | grep ${args.name}

	// 	"
	
	// osal.exec(cmd: cmd, stdout:true, debug: false)!
}


fn obj_init()!{

}


fn start_pre()!{
	
}

fn start_post()!{
	
}

fn stop_pre()!{
	
}

fn stop_post()!{
	
}

