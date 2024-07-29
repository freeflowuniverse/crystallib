module coredns

import freeflowuniverse.crystallib.core.pathlib
import os



pub fn configure(args_ InstallArgs) ! {
	mut args := args_

	if args.config_url.len>0{
		//TODO use gittools to pull url and fill in path
		//use /root/code/github/freeflowuniverse/crystallib/crystallib/develop/gittools/codeget.v
	}

	if args.config_path.len==0{
		args.config_path = '${os.home_dir()}/hero/cfg/Corefile'
	}


	if args.dnszones_url.len>0{
		//TODO use gittools to pull url and fill in path
		//use /root/code/github/freeflowuniverse/crystallib/crystallib/develop/gittools/codeget.v
	}

	if args.dnszones_path.len==0{
		args.dnszones_path='${os.home_dir()}/hero/cfg/dnszones'
	}


	mycorefile := $tmpl('templates/Corefile')
	mut path := pathlib.get_file(path: args.config_path, create: true)!
	path.write(mycorefile)!
}


pub fn example_configure(args_ InstallArgs) ! {
	mut args := args_

	exampledbfile := $tmpl('templates/db.example.org')

	mut path_testzone := pathlib.get_file(path: '${dnszones_dir}/db.example.org', create: true)!
	path_testzone.template_write(..., true)!

	//TODO: write in dnszones_path

}
