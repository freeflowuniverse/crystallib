module podman

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset     bool
	uninstall bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	mut version := '5.1.0'

	if osal.platform() == .arch {
		// no idea why this is but the version shown is older
		version = '4.9.2'
	}

	// if  args.uninstall {
	// 		console.print_header('uninstall podman')
	// 		uninstall()!
	// 		console.print_debug(' - ok')
	// 	}

	res := os.execute('${osal.profile_path_source_and()} podman -v')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.contains('podman version'))
		if r.len != 1 {
			return error("couldn't parse podman version, expected 'podman version' on 1 row.\n${res.output}")
		}

		v := texttools.version(r[0].all_after('version'))
		if v < texttools.version(version) {
			// console.print_debug(v)
			// console.print_debug(texttools.version(version))
			// console.print_debug(version)
			// if true{panic("s")}
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install podman')

	mut url := ''
	base.install()!
	mut dest := '/tmp/podman.pkg'
	if osal.platform() == .osx {
		if osal.cputype() == .arm {
			url = 'https://github.com/containers/podman/releases/download/v${version}/podman-installer-macos-arm64.pkg'
		} else {
			url = 'https://github.com/containers/podman/releases/download/v${version}/podman-installer-macos-amd64.pkg'
		}

		console.print_header('download ${url}')
		osal.download(
			url: url
			minsize_kb: 75000
			reset: args.reset
			dest: dest
		)!

		cmd := '
		sudo installer -pkg ${dest} -target /
		'
		osal.execute_interactive(cmd)!
		console.print_header(' - pkg installed.')
	} else if osal.platform() in [.alpine, .arch, .ubuntu] {
		osal.package_install('podman,podman-docker,buildah')!
		osal.exec(cmd: 'systemctl start podman.socket')!

		// TODO:
		// add: unqualified-search-registries = ["docker.io"]
		// to: /etc/containers/registries.conf
		// totest: podman run --name basic_httpd -dt -p 8080:80/tcp docker.io/nginx
		// curl http://localhost:8080
		// https://github.com/containers/podman/blob/main/docs/tutorials/podman_tutorial.md

		// mut t:="arm"
		// if osal.cputype() == .arm {
		// 	url = 'https://github.com/containers/podman/releases/download/v${version}/podman-remote-static-linux_arm64.tar.gz'
		// } else {
		// 	t="amd"
		// 	url = 'https://github.com/containers/podman/releases/download/v${version}/podman-remote-static-linux_amd64.tar.gz'
		// }
		// dest = '/tmp/podman.tar.gz'

		// console.print_header('download ${url}')
		// osal.download(
		// 	url: url
		// 	minsize_kb: 18000
		// 	reset: args.reset
		// 	expand_dir: '/tmp/podman'
		// )!

		// osal.cmd_add(
		// 	cmdname: 'podman'
		// 	source: "/tmp/podman/bin/podman-remote-static-linux_${t}64"
		// )!
	}

	if exists()! {
		console.print_header(' - podman exists check ok.')
	}
}

// @[params]
// pub struct ExtensionsInstallArgs {
// pub mut:
// 	extensions string
// 	default    bool = true
// }

pub fn exists() !bool {
	return osal.cmd_exists('podman')
}

pub fn uninstall() ! {
	// cmd := '
	// // # Quit Google Chrome
	// // osascript -e \'quit app "Google Chrome"\'

	// // # Wait a bit to ensure Chrome has completely quit
	// // sleep 2

	// '
	// osal.exec(cmd: cmd)!
}
