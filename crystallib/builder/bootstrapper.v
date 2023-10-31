module builder

import os
import freeflowuniverse.crystallib.core.pathlib

const crystalpath_ = os.dir(@FILE) + '/../'

const heropath_ = os.dir(@FILE) + '/../../cli'

// to use do something like: export NODES="195.192.213.3" .
pub fn bootstrapper() ! {
	mut b := new()!
	nodes_str := os.environ()['NODES'] or {
		panic('need NODES in env var\n.Do something like: export NODES="195.192.213.3" ')
	}
	for nodestr in nodes_str.split(',') {
		ipaddr := nodestr.trim_space()
		mut n := b.node_new(ipaddr: ipaddr)!

		// println(n)

		n.crystal_install()!

		// will only upload if changes for the cli's
		mut heropath := pathlib.get_dir(path: os.abs_path(builder.heropath_), create: false)!
		herohex := heropath.md5hex()!
		herohexsystem := n.done_get('herohex') or { '' }
		if herohex != herohexsystem {
			n.upload(
				source: heropath.path
				dest: '~/code/github/freeflowuniverse/crystallib/cli'
				ignore: [
					'.git/*',
				]
				delete: true
			)!
			n.done_set('herohex', herohex)!
		}

		// will only upload if changes
		mut crystalpath := pathlib.get_dir(path: os.abs_path(builder.crystalpath_), create: false)!
		crystalhex := crystalpath.md5hex()!
		crystalhexsystem := n.done_get('crystalhex') or { '' }
		if crystalhex != crystalhexsystem {
			n.upload(
				source: crystalpath.path
				dest: '~/.vmodules/freeflowuniverse/crystallib/'
				ignore: [
					'.git/*',
				]
				delete: true
			)!
			// means new crystal, we need to now build hero again
			n.exec_cmd(
				cmd: 'bash -c ~/code/github/freeflowuniverse/crystallib/cli/hero/compile_bin.sh'
				reset: true
				description: 'hero build'
			)!
			n.done_set('crystalhex', crystalhex)!
		}

		if true {
			println(crystalpath)
			panic('sdsdsds')
		}

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
	}
}

fn (mut node Node) bootstrap_args() map[string]string {
	mut res := map[string]string{}
	env := node.environ_get() or { panic('cant get environ') }
	res['HOME'] = env['HOME'] or { panic('cant find HOME in environ') }
	res['USER'] = env['USER'] or { panic('cant find USER in environ') }
	res['CLBRANCH'] = 'development'
	res['DIR_CODE'] = '${res['HOME']}/code'
	return res
}

fn (mut node Node) github_keyscan() ! {
	if node.platform == PlatformType.ubuntu {
		upgrade_cmds := '
			mkdir -p ~/.ssh
			if ! grep github.com ~/.ssh/known_hosts > /dev/null
			then
				ssh-keyscan github.com >> ~/.ssh/known_hosts
			fi
			git config --global pull.rebase false
			'
		node.exec_cmd(
			cmd: upgrade_cmds
			reset: false
			description: 'keyscan'
		)!
	}
}

fn (mut node Node) crystal_install() ! {
	if node.platform == PlatformType.ubuntu {
		node.github_keyscan()!

		args := node.bootstrap_args()
		mut crystal_install := $tmpl('templates/crystal_install.sh').replace('??', '@').replace('!!',
			'$')
		crystal_install += 'v_install\n'
		// mut f:=pathlib.get_file(path:"/tmp/v_install.sh",create:true)!
		// f.write(crystal_install)!
		node.exec_cmd(
			cmd: crystal_install
			reset: false
			description: 'crystal_install'
		)!
	}
}
