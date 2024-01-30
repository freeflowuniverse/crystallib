module builder

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import v.embed_file

const crystalpath_ = os.dir(@FILE) + '/../'

pub struct BootStrapper {
pub mut:
	embedded_files map[string]embed_file.EmbedFileData @[skip; str: skip]
}

@[params]
pub struct BootstrapperArgs {
pub mut:
	name  string = 'bootstrap'
	addr  string // format:  root@something:33, 192.168.7.7:222, 192.168.7.7, despiegk@something
	reset bool
	debug bool
}

fn (mut bs BootStrapper) load() {
	bs.embedded_files['installer_base.sh'] = $embed_file('../../scripts/installer_base.sh')
}

// to use do something like: export NODES="195.192.213.3" .
pub fn bootstrapper() BootStrapper {
	mut bs := BootStrapper{}
	bs.load()
	return bs
}

pub fn (mut bs BootStrapper) run(args_ BootstrapperArgs) ! {
	mut args := args_
	addr := texttools.to_array(args.addr)
	mut b := new()!
	mut counter := 0
	for a in addr {
		counter += 1
		name := '${args.name}_${counter}'
		mut n := b.node_new(ipaddr: a, name: name)!
		n.crystal_install()!
	}
}

pub fn (mut node Node) upgrade() ! {
	mut bs := bootstrapper()
	installer_base_content_ := bs.embedded_files['installer_base.sh'] or { panic('bug') }
	installer_base_content := installer_base_content_.to_string()
	cmd := '${installer_base_content}\n'
	node.exec_cmd(
		cmd: cmd
		period: 48 * 3600
		reset: false
		description: 'upgrade operating system packages'
	)!
}

pub fn (mut node Node) hero_install() ! {
	panic('implement')
	// if node.platform == .osx {
	// 	// we have no choice then to do it interactive
	// 	myenv := node.environ_get()!
	// 	homedir := myenv['HOME'] or { return error("can't find HOME in env") }
	// 	node.exec_silent('mkdir -p ${homedir}/hero/bin')!
	// 	node.file_write('${homedir}/hero/bin/install.sh', cmd)!
	// 	node.exec_silent('chmod +x ${homedir}/hero/bin/install.sh')!
	// 	node.exec_interactive('${homedir}/hero/bin/install.sh')!
	// } else {
	// 	node.exec_cmd(cmd: cmd)!
	// }
}

pub fn (mut node Node) crystal_install() ! {
	mut bs := bootstrapper()
	installer_base_content_ := bs.embedded_files['installer_base.sh'] or { panic('bug') }
	installer_base_content := installer_base_content_.to_string()
	cmd := '
		${installer_base_content}
		
		rm -f /usr/local/bin/hero
		freeflow_dev_env_install

		~/code/github/freeflowuniverse/crystallib/install.sh
		
		echo HERO, V, CRYSTAL ALL INSTALL OK
		echo WE ARE READY TO HERO...
		
		'
	node.exec_cmd(cmd: cmd)!
}

@[params]
pub struct CrystalUpdateArgs {
pub mut:
	all        bool
	fast_rsync bool = true
}

// sync local crystal code to rmote and then compile hero
pub fn (mut node Node) crystal_update(args CrystalUpdateArgs) ! {
	if args.all {
		node.sync_code('crystal', builder.crystalpath_ + '/..', '~/code/github/freeflowuniverse/crystallib',
			args.fast_rsync)!
	} else {
		node.sync_code('crystal_lib', builder.crystalpath_, '~/code/github/freeflowuniverse/crystallib/crystallib',
			args.fast_rsync)!
	}
}

pub fn (mut node Node) sync_code(name string, src_ string, dest string, fast_rsync bool) ! {
	mut src := pathlib.get_dir(path: os.abs_path(src_), create: false)!
	node.upload(
		source: src.path
		dest: dest
		ignore: [
			'.git/*',
			'_archive',
			'.vscode',
			'examples',
		]
		delete: true
		fast_rsync: fast_rsync
	)!
}

// sync local crystal code to rmote and then compile hero
pub fn (mut node Node) hero_compile_debug() ! {
	if !node.file_exists('~/code/github/freeflowuniverse/crystallib/cli/readme.md') {
		node.crystal_install()!
	}
	node.crystal_update()!
	node.exec_cmd(
		cmd: '
		~/code/github/freeflowuniverse/crystallib/install.sh
		~/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh		
		'
	)!
}

@[params]
pub struct VScriptArgs {
pub mut:
	path           string
	crystal_update bool
}

pub fn (mut node Node) vscript(args_ VScriptArgs) ! {
	mut args := args_
	if args.crystal_update {
		node.crystal_update()!
	}
	mut p := pathlib.get_file(path: args.path, create: false)!

	node.upload(source: p.path, dest: '/tmp/remote_${p.name()}')!
	node.exec_cmd(
		cmd: '
		cd /tmp/remote
		v -w -enable-globals /tmp/remote_${p.name()}
		'
	)!
}
