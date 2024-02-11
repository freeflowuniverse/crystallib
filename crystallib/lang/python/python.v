module python

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.lang.python
import freeflowuniverse.crystallib.core.texttools
import os

pub struct PythonEnv {
pub mut:
	name string
	path pathlib.Path
	db   fskvs.DB
}

@[params]
pub struct PythonEnvArgs {
pub mut:
	name  string = 'default'
	reset bool
}

pub fn new(args_ PythonEnvArgs) !PythonEnv {
	mut args := args_
	name := texttools.name_fix(args.name)

	pp := '${os.home_dir()}/hero/python/${name}'
	mut isnew := false
	if !os.exists(pp) {
		python.install()!
		isnew = true
	}
	mut cdb := fskvs.contextdb_get()!
	mut db := cdb.db_get(dbname: 'python_${name}')!
	py := PythonEnv{
		name: name
		path: pathlib.get_dir(path: pp, create: true)!
		db: db
	}

	if isnew {
		py.init_env()!
	}
	return py
}

// comma separated list of packages to install
pub fn (py PythonEnv) init_env() ! {
	cmd := '
	cd ${py.path.path}
	python3 -m venv .
	'
	osal.exec(cmd: cmd)!
}

// comma separated list of packages to install
pub fn (py PythonEnv) update() ! {
	cmd := '
	cd ${py.path.path}
	source bin/activate
	python3 -m pip install --upgrade pip
	'
	osal.exec(cmd: cmd)!
}

// comma separated list of packages to install
pub fn (mut py PythonEnv) pip(packages string) ! {
	mut out := []string{}
	mut pips := py.pips_done()
	for i in packages.split(',') {
		if i !in pips {
			out << '${i.trim_space()}'
		}
	}
	if out.len == 0 {
		return
	}
	packages2 := out.join(' ')
	cmd := '
	cd ${py.path.path}
	source bin/activate
	pip3 install ${packages2} -q
	'
	osal.exec(cmd: cmd)!
	for o in out {
		py.pips_done_add(o)!
	}
}

pub fn (mut py PythonEnv) pips_done_reset() {
	py.db.delete('pips_${py.name}') or {}
}

pub fn (mut py PythonEnv) pips_done() []string {
	mut res := []string{}
	pips := py.db.get('pips_${py.name}') or { '' }
	for pip_ in pips.split_into_lines() {
		pip := pip_.trim_space()
		if pip !in res && pip.len > 0 {
			res << pip
		}
	}
	return res
}

pub fn (mut py PythonEnv) pips_done_add(name string) ! {
	mut pips := py.pips_done()
	if name in pips {
		return
	}
	pips << name
	out := pips.join_lines()
	py.db.set('pips_${py.name}', out)!
}

pub fn (mut py PythonEnv) pips_done_check(name string) bool {
	mut pips := py.pips_done()
	if name in pips {
		return true
	}
	return false
}

// remember the requirements list for all pips
pub fn (mut py PythonEnv) freeze(name string) ! {
	cmd := '
	cd ${py.path.path}
	source bin/activate
	python3 -m pip freeze
	'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not execute freeze.\n${res}\n${cmd}')
	}
	py.db.set('freeze_${name}', res.output)!
}

// remember the requirements list for all pips
pub fn (mut py PythonEnv) unfreeze(name string) ! {
	requirements := py.db.get('freeze_${name}')!
	mut p := py.path.file_get_new('requirements.txt')!
	p.write(requirements)!
	cmd := '
	cd ${py.path.path}
	source bin/activate
	python3 -m pip install -r requirements.txt
	'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not execute unfreeze.\n${res}\n${cmd}')
	}
}