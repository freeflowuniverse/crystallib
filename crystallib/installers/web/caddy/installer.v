module caddy

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.zinit as zinitmgmt
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
	start bool
	restart bool
	stop bool
	homedir string
	file_path string // path to caddyfile
	file_url string // path to caddyfile
}

// install caddy will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '2.8.4'


	res := os.execute('${osal.profile_path_source_and()} caddy version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().len > 0)
		if r.len != 1 {
			return error("couldn't parse dagu version.\n${res.output}")
		}
		if texttools.version(version) > texttools.version(r[0]) {
			args.reset = true
		}
	} else {
		args.reset = true
	}


	if args.reset {
		console.print_header('install caddy')

		mut url := ''
		if osal.is_linux_arm() {
			url = 'https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_arm64.tar.gz'
		} else if osal.is_linux_intel() {
			url = 'https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_amd64.tar.gz'
		} else if osal.is_osx_arm() {
			url = 'https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_darwin_arm64.tar.gz'
		} else if osal.is_osx_intel() {
			url = 'https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_darwin_amd64.tar.gz'
		} else {
			return error('unsported platform')
		}

		mut dest := osal.download(
			url: url
			minsize_kb: 10000
			expand_dir: '/tmp/caddyserver'
		)!

		mut binpath := dest.file_get('caddy')!
		osal.cmd_add(
			cmdname: 'caddy'
			source: binpath.path
		)!
	}

	if args.restart {
		restart(args)!
		return
	}

	if args.start {
		start(args)!
	}
}

@[params]
pub struct WebConfig {
pub mut:
	path   string = '/var/www'
	domain string
}

// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn configure_examples(config WebConfig) ! {
	mut config_file := $tmpl('templates/caddyfile_default')
	if config.domain.len > 0 {
		config_file = $tmpl('templates/caddyfile_domain')
	}
	install()!
	os.mkdir_all(config.path)!

	default_html := '
	<!DOCTYPE html>
	<html>
		<head>
			<title>Caddy has now been installed.</title>
		</head>
		<body>
			Caddy has been installed and is working in /var/www.
		</body>
	</html>
	'
	osal.file_write('${config.path}/index.html', default_html)!

	configuration_set(content: config_file)!
}

pub fn configuration_get() !string {
	c := osal.file_read('/etc/caddy/Caddyfile')!
	return c
}

@[params]
pub struct ConfigurationArgs {
pub mut:
	content string
	path    string
	restart bool = true
}

pub fn configuration_set(args_ ConfigurationArgs) ! {
	console.print_header('Caddy config set')
	mut args := args_
	if args.content == '' && args.path == '' {
		return error('need to specify content or path.')
	}
	if args.content.len > 0 {
		args.content = texttools.dedent(args.content)
		if !os.exists('/etc/caddy') {
			os.mkdir_all('/etc/caddy')!
		}
		osal.file_write('/etc/caddy/Caddyfile', args.content)!
	} else {
		mut p := pathlib.get_file(path: args.path, create: true)!
		content := p.read()!
		if !os.exists('/etc/caddy') {
			os.mkdir_all('/etc/caddy')!
		}
		osal.file_write('/etc/caddy/Caddyfile', content)!
	}

	if args.restart {
		restart()!
	}
}

@[params]
pub struct StartArgs {
pub mut:
	zinit bool
}

// start caddy
pub fn start(args_ InstallArgs) ! {
	mut args := args_
	console.print_header('caddy start')

	if args.homedir == '' {
		args.homedir = '/tmp/caddy'
	}

	if !os.exists('/etc/caddy/Caddyfile') {
		return error("didn't find caddyfile")
	}

	cmd:= 'caddy run --config /etc/caddy/Caddyfile'

	mut sm := startupmanager.get()!

	sm.start(
		name: 'caddy'
		cmd: cmd
	)!

}

pub fn stop() ! {
	console.print_header('Caddy Stop')
	mut sm := startupmanager.get()!
	sm.stop('caddy')!

}

pub fn restart(args InstallArgs) ! {
	stop()!
	start(args)!
}
