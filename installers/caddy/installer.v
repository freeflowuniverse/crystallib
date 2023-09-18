module caddy

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.downloader
import freeflowuniverse.crystallib.installers.base
import os

// install caddy will return true if it was already installed
pub fn install() ! {
	// make sure we install base on the node
	base.install()!

	// install caddy if it was already done will return true
	println(' - package_install install caddy')

	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	downloader.download(url:"https://github.com/caddyserver/caddy/releases/download/v2.7.4/caddy_2.7.4_linux_arm64.tar.gz",
		minsize_kb:10000, name:"caddy", expand:true)!


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
pub fn install_configure(config WebConfig) ! {
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

	configuration_set(config_file)!
}

pub fn configuration_get() !string {
	c := osal.file_read('/etc/caddy/Caddyfile')!
	return c
}

pub fn configuration_set(config_file string) ! {
	osal.file_write('/etc/caddy/Caddyfile', config_file)!
	restart()!
}

// start caddy
pub fn start() ! {
	osal.execute_silent('caddy start --config /etc/caddy/Caddyfile')!
}

pub fn stop() ! {
	osal.execute_silent('caddy stop') or {}
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
