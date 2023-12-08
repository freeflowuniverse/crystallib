module python

import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.python
import freeflowuniverse.crystallib.core.texttools
import os

pub struct PythonEnv {
pub mut:
	name string
	path pathlib.Path
}

@[params]
pub struct PythonEnvArgs {
pub mut:
	name string = 'default'
	reset bool
}


pub fn new(args_ PythonEnvArgs) !PythonEnv {
	mut args:=args_

	python.install()!
	name:=texttools.name_fix(args.name)
	py:=PythonEnv{
		name: name
		path : pathlib.get_dir(path:"${os.home_dir()}/hero/python/${name}",create:true)!
	}

	py.init_env()!

	return py
}

// comma separated list of packages to install
pub fn (py PythonEnv) init_env() ! {
	cmd:='
	cd ${py.path.path}
	python3 -m venv .
	'
	osal.exec(cmd:cmd)!
}


// comma separated list of packages to install
pub fn (py PythonEnv) update() ! {
	cmd:='
	cd ${py.path.path}
	source bin/activate
	python3 -m pip install --upgrade pip
	'
	osal.exec(cmd:cmd)!
}



// comma separated list of packages to install
pub fn (py PythonEnv) pip(packages string) ! {
	mut out:=[]string{}
	for i in packages.split(","){
		out<<"$i"
	}
	packages2:=out.join(" ")
	cmd:='
	cd ${py.path.path}
	source bin/activate
	pip3 install ${packages2} -q
	'
	osal.exec(cmd:cmd)!
}

