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
		10_installer_v.sh
		11_installer_crystallib.sh
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

	out2 := '${out}\nfreeflow_dev_env_install\n\n\n V & CRYSTAL INSTALL OK\n'

	mut p2 := pathlib.get_file(path: '${base.scriptspath}/installer.sh', create: true)!
	p2.write(out2)!
	os.chmod(p2.path, 0o777)!

	out3 := '${out}\nhero_build\n\n\necho HERO, V, CRYSTAL ALL OK\necho WE ARE READY TO HERO...'

	mut p3 := pathlib.get_file(path: '${base.scriptspath}/build_hero.sh', create: true)!
	p3.write(out3)!
	os.chmod(p3.path, 0o777)!

	mut p4 := pathlib.get_dir(path: '${base.scriptspath}', create: false)!
	return p4.path
}
