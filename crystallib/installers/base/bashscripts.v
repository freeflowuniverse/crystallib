module base

import freeflowuniverse.crystallib.core.pathlib
import os

const scriptspath = os.dir(@FILE) + '/../../../scripts'

pub fn bash_installers_package() !string {
	l := '
		1_init.sh
		2_myplatform.sh	
		3_gittools.sh
		4_package.sh
		5_exec.sh
		6_reset.sh
		7_zinit.sh
		8_osupdate.sh
		9_installer_redis.sh
		10_installer_v.sh
		11_installer_crystallib.sh
		12_installer_hero.sh
		20_installers.sh
	'
	mut out := ''
	for mut name in l.split_into_lines() {
		name = name.trim_space()
		if name == '' {
			continue
		}
		mut p := pathlib.get_file(path: '${base.scriptspath}/lib/${name}', create: false)!
		c := p.read()!
		out += c
	}

	mut p := pathlib.get_file(path: '${base.scriptspath}/installer_base.sh', create: true)!
	p.write(out)!
	os.chmod(p.path, 0o777)!

	out += '\nfreeflow_dev_env_install\n'

	mut p2 := pathlib.get_file(path: '${base.scriptspath}/installer.sh', create: true)!
	p2.write(out)!
	os.chmod(p2.path, 0o777)!

	mut p3 := pathlib.get_dir(path: '${base.scriptspath}', create: false)!
	return p3.path
}
