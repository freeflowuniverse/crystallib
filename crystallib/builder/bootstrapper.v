module builder

import os
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.pathlib
import v.embed_file

const crystalpath_ = os.dir(@FILE) + '/../'

pub struct BootStrapper {
pub mut:
	embedded_files map[string]embed_file.EmbedFileData @[skip; str: skip]
}

@[params]
pub struct BootstrapperArgs {
pub mut:
	name  string
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
	for a in addr {
		mut n := b.node_new(ipaddr: a, name: args.name)!
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

pub fn (mut node Node) crystal_install() ! {
	mut bs := bootstrapper()
	installer_base_content_ := bs.embedded_files['installer_base.sh'] or { panic('bug') }
	installer_base_content := installer_base_content_.to_string()
	cmd := '${installer_base_content}\nfreeflow_dev_env_install\n'
	if node.platform == .osx {
		// we have no choice then to do it interactive
		myenv := node.environ_get()!
		homedir := myenv['HOME'] or { return error("can't find HOME in env") }
		node.exec_silent('mkdir -p ${homedir}/hero/bin')!
		node.file_write('${homedir}/hero/bin/install.sh', cmd)!
		node.exec_silent('chmod +x ${homedir}/hero/bin/install.sh')!
		node.exec_interactive('${homedir}/hero/bin/install.sh')!
	} else {
		node.exec_cmd(cmd: cmd)!
	}
}

// println(n)
// // will only upload if changes for the cli's
// mut heropath := pathlib.get_dir(path: os.abs_path(builder.heropath_), create: false)!
// herohex := heropath.md5hex()!
// herohexsystem := n.done_get('herohex') or { '' }
// if herohex != herohexsystem {
// 	n.upload(
// 		source: heropath.path
// 		dest: '~/code/github/freeflowuniverse/crystallib/cli'
// 		ignore: [
// 			'.git/*',
// 		]
// 		delete: true
// 	)!
// 	n.done_set('herohex', herohex)!
// }

// // will only upload if changes
// mut crystalpath := pathlib.get_dir(path: os.abs_path(builder.crystalpath_), create: false)!
// crystalhex := crystalpath.md5hex()!
// crystalhexsystem := n.done_get('crystalhex') or { '' }
// if crystalhex != crystalhexsystem {
// 	n.upload(
// 		source: crystalpath.path
// 		dest: '~/.vmodules/freeflowuniverse/crystallib/'
// 		ignore: [
// 			'.git/*',
// 		]
// 		delete: true
// 	)!
// 	// means new crystal, we need to now build hero again
// 	n.exec_cmd(
// 		cmd: 'bash -c ~/code/github/freeflowuniverse/crystallib/cli/hero/compile_bin.sh'
// 		reset: true
// 		description: 'hero build'
// 	)!
// 	n.done_set('crystalhex', crystalhex)!
// }

// if true {
// 	println(crystalpath)
// 	panic('sdsdsds')
// }

// if !n.done_exists('keydb') {
// 	n.exec_cmd(
// 		cmd: '
// 			echo "deb https://download.keydb.dev/open-source-dist $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/keydb.list
// 			wget -O /etc/apt/trusted.gpg.d/keydb.gpg https://download.keydb.dev/open-source-dist/keyring.gpg
// 			apt update
// 			apt install keydb
// 			'
// 	)!
// 	n.done_set('keydb', 'OK')!
// }
