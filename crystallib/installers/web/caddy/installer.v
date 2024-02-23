module caddy

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.infra.zinit
import freeflowuniverse.crystallib.osal.zinit as zinitmgmt
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal.screen

import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install caddy will return true if it was already installed
pub fn install(args InstallArgs) ! {
	// make sure we install base on the node
	base.install()!
	

	if args.reset == false && osal.done_exists('install_caddy') {
		return
	}

	// install caddy if it was already done will return true
	console.print_header('package_install install caddy')

	if ! osal.is_linux() {
		return error('only support linux for now')
	}
	mut dest := osal.download(
		url: 'https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.tar.gz'
		minsize_kb: 10000
		reset: true
		expand_dir: '/tmp/caddyserver'
	)!

	mut caddyfile := dest.file_get('caddy')! // file in the dest
	caddyfile.copy(dest: '/usr/local/bin', delete: true)!
	caddyfile.chmod(0o770)! // includes read & write & execute

	println(' CADDY INSTALLED')

	osal.done_set('install_caddy', 'OK')!
	return
}

@[params]
pub struct WebConfig {
pub mut:
	path   string = '/var/www'
	domain string = ''
}

// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn configure_examples(config WebConfig) ! {
	mut config_file := $tmpl('templates/caddyfile_default')
	if config.domain.len>0 {
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
	zinit bool = true
}


// start caddy
pub fn start(args StartArgs) ! {
	console.print_header('Caddy Start')
	if !os.exists('/etc/caddy/Caddyfile') {
		return error("didn't find caddyfile")
	}
	if args.zinit{
		zinit.install()!
		mut z := zinitmgmt.new()!
		p := z.process_new(
			name: 'caddy'
			cmd: '
				caddy run --config /etc/caddy/Caddyfile
				echo CADDY STOPPED
				/bin/bash'
		)!

		p.start()!
	}else{
		mut scr:=screen.new(reset:false)!
		mut s2:=scr.add(name:"caddy",cmd: 'caddy run --config /etc/caddy/Caddyfile')!
	}
}

pub fn stop() ! {
	console.print_header('Caddy Stop')
	// mut scr:=screen.new(reset:false)!
	// scr.kill("caddy")!
	// osal.process_kill_recursive(name:"caddy")! //kills myself
}

pub fn restart() ! {
	stop()!
	start()!
}
