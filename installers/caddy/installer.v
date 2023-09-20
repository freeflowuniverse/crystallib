module caddy

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import os

[params]
pub struct InstallArgs{
pub mut:
	reset bool
}

// install caddy will return true if it was already installed
pub fn install(args InstallArgs) ! {
	// make sure we install base on the node
	base.install()!

	if args.reset==false && osal.done_exists('install_caddy'){
		return
	}

	// install caddy if it was already done will return true
	println(' - package_install install caddy')

	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	mut dest:=osal.download(url:"https://github.com/caddyserver/caddy/releases/download/v2.7.4/caddy_2.7.4_linux_arm64.tar.gz",
		minsize_kb:10000,reset:true,expand_dir:"/tmp/caddyserver")!

	mut caddyfile:=dest.file_get("caddy")! //file in the dest
	caddyfile.copy("/usr/local/bin")! 
	caddyfile.chmod(0o770)! //includes read & write & execute

	osal.done_set('install_caddy', 'OK')!
	return
}

pub struct WebConfig {
pub mut:

	path   string = '/var/www'
	domain string = 'default.com'
}

// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn configure_examples(config WebConfig) ! {
	mut config_file := $tmpl('templates/caddyfile_default')
	install()!
	os.mkdir_all(config.path)!

	default_html := '
	<!DOCTYPE html>
	<html>
		<head>
			<title>Caddy has now been installed.</title>
		</head>
		<body>
			Page loaded at: {{now | date "Mon Jan 2 15:04:05 MST 2006"}}
		</body>
	</html>
	'
	osal.file_write('${config.path}/index.html', default_html)!

	configuration_set(content:config_file)!
}

pub fn configuration_get() !string {
	c := osal.file_read('/etc/caddy/Caddyfile')!
	return c
}

[params]
pub struct ConfigurationArgs{
pub mut:
	content string
	path string
	restart bool = true
}

pub fn configuration_set(args_ ConfigurationArgs) ! {
	mut args:=args_
	if args.content=="" && args.path==""{
		return error("need to specify content or path.")
	}
	if args.content.len>0{
		args.content=texttools.dedent(args.content)
		osal.file_write('/etc/caddy/Caddyfile', args.content)!
	}else{
		mut p:=pathlib.get_file(args.path,true)!
		content:= p.read()!
		osal.file_write('/etc/caddy/Caddyfile', content)!
	}
	
	if args.restart{
		restart()!
	}
}

// start caddy
pub fn start() ! {
	mut t := tmux.new()!
	mut w:=t.window_new(name: 'caddy', cmd:'caddy start --config /etc/caddy/Caddyfile')!	
	// osal.execute_silent('caddy start --config /etc/caddy/Caddyfile')!
}

pub fn stop() ! {
	mut t := tmux.new()!
	t.window_delete(name: 'caddy')!
	// osal.execute_silent('caddy stop') or {}
	// TODO: should do some better test to check if caddy is really stopped
}

pub fn restart() ! {
	cmd := '
	set +ex
	caddy stop
	set -ex
	caddy start --config /etc/caddy/Caddyfile
	'
	osal.execute_silent(cmd)!
}



// if cmd_exists('caddy') {
// 	println('Caddy was already installed.')
// 	//! should we set caddy as done here !
// 	return
// }
// //TODO: better to start from a build one
// osal.execute_silent("
// 	sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https gpg sudo
// 	rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg
// 	curl -1sLfk 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
// 	curl -1sLfk 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
// 	apt update
// 	apt install caddy
// ") or {
// 	return error('Cannot install caddy.\n${err}')
// }