module caddy

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.base

// install caddy will return true if it was already installed
pub fn install(mut node builder.Node) ! {
	// make sure we install base on the node
	base.install(mut node)!

	// install caddy if it was already done will return true
	println(' - ${node.name}: install caddy')

	if node.platform != .ubuntu {
		return error('only support ubuntu for now')
	}

	if node.command_exists('caddy') {
		println('Caddy was already installed.')
		//! should we set caddy as done here !
		return
	}

	node.exec("
		sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https gpg sudo
		rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLfk 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLfk 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
		apt update
		apt install caddy
	") or {
		return error('Cannot install caddy.\n${err}')
	}

	node.done_set('install_caddy', 'OK')!
	return
}

pub struct WebConfig {
pub mut:
	node   &builder.Node
	path   string = '/var/www'
	domain string = 'default.com'
}

// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn install_configure(config WebConfig) ! {
	mut config_file := $tmpl('templates/caddyfile_default')
	mut node := config.node
	install(mut node)!
	node.exec('mkdir -p ${config.path}')!

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
	node.file_write('${config.path}/index.html', default_html)!

	configuration_set(mut node, config_file)!
}

pub fn configuration_get(mut node builder.Node) !string {
	c := node.file_read('/etc/caddy/Caddyfile')!
	return c
}

pub fn configuration_set(mut node builder.Node, config_file string) ! {
	node.file_write('/etc/caddy/Caddyfile', config_file)!
	restart(mut node)!
}

// start caddy
pub fn start(mut node builder.Node) ! {
	node.exec_silent('caddy start --config /etc/caddy/Caddyfile')!
}

pub fn stop(mut node builder.Node) ! {
	node.exec_silent('caddy stop') or {}
	// TODO: should do some better test to check if caddy is really stopped
}

pub fn restart(mut node builder.Node) ! {
	cmd := '
	set +ex
	caddy stop
	set -ex
	caddy start --config /etc/caddy/Caddyfile
	'
	node.exec(cmd)!
}
