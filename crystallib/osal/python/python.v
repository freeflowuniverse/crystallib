module python

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.python
import freeflowuniverse.crystallib.core.texttools
import os

pub struct PythonEnv {
pub mut:
	name string
	path pathlib.Path
	db   fskvs.KVS
}

@[params]
pub struct PythonEnvArgs {
pub mut:
	name  string = 'default'
	reset bool
}

pub fn new(args_ PythonEnvArgs) !PythonEnv {
	mut args := args_

	python.install()!
	name := texttools.name_fix(args.name)
	mut db := fskvs.new(name: 'python_${name}')!
	py := PythonEnv{
		name: name
		path: pathlib.get_dir(path: '${os.home_dir()}/hero/python/${name}', create: true)!
		db: db
	}

	py.init_env()!

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

@[params]
pub struct PythonExecArgs {
pub mut:
	cmd                string @[required]
	result_delimiter   string = '==RESULT=='
	ok_delimiter       string = '==OK=='
	python_script_name string // if used will put it in root of the sandbox under that name
}

pub fn (py PythonEnv) exec(args PythonExecArgs) !string {
	mut cmd := texttools.dedent(args.cmd)

	cmd += "\n\nprint(\"${args.ok_delimiter}\")\n"

	mut scriptpath := ''
	if args.python_script_name.len > 0 {
		scriptpath = '${py.path.path}/${args.python_script_name}.py'
		mut p := pathlib.get_file(path: scriptpath, create: true)!
		p.write(cmd)!
	} else {
		scriptpath = pathlib.temp_write(text: cmd, ext: 'py') or {
			return error('error: cannot write script to execute: ${err}')
		}
	}
	// println(" - scriptpath: ${scriptpath}")
	os.chmod(scriptpath, 0o777)!

	cmd2 := '
	cd ${py.path.path}
	source bin/activate
	python3 ${scriptpath}
	'
	job := osal.exec(cmd: cmd2, stdout: false, raise_error: false)!

	if job.exit_code > 0 {
		// means error
		mut msg := ' - error in execution of python script: ${scriptpath}\n'
		msg += 'ERROR:\n'
		msg += job.error.join_lines()
		return error(msg)
	}

	// println(job)

	mut o := []string{}
	mut start := false
	for l in job.output {
		if l.trim_space().starts_with(args.result_delimiter) {
			start = true
			continue
		}
		if l.trim_space().starts_with(args.ok_delimiter) {
			break
		}
		if start {
			o << l
		}
	}

	return o.join_lines()
}
