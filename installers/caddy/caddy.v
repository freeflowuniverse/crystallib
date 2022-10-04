module caddy
import installers.base
// import freeflowuniverse.crystallib.pathlib

// install caddy will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install caddy if it was already done will return true
	println(' - $node.name: install caddy')
	if !(i.state == .reset) && node.done_exists('install_caddy') {
		println('    $node.name: was already done')
		return
	}


 	if node.platform != .ubuntu {
		return error("only support ubuntu for now")
	}

	base.get_install(mut node)?

	if node.command_exists('caddy') {
		println('Caddy was already installed.')
		//? should we set caddy as done here ?
		return
	}


	node.exec("
		sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https gpg sudo
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
		apt update
		apt install caddy
	") or {
		return error('Cannot install caddy.\n$err')
	}

	node.done_set('install_caddy', 'OK')?
	return
}

// configure caddy as default webserver & start
pub fn (mut i Installer) configure_webserver_default(path string,domain string) ? {
	mut node := i.node
	mut config_file := $tmpl('templates/caddyfile_default')
	node.exec("mkdir -p $path")?

	default_html :='
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
	node.file_write("$path/index.html",default_html)?

	i.configuration_set(config_file)?


}


pub fn (mut i Installer) configuration_get() ?string {
	mut node := i.node
	c:=node.file_read("/etc/caddy/Caddyfile")?
	return c
}


pub fn (mut i Installer) configuration_set(config_file string) ? {
	mut node := i.node
	node.file_write("/etc/caddy/Caddyfile",config_file)?
	i.restart()?
}


// start caddy
pub fn (mut i Installer) start() ? {
	mut node := i.node
	node.exec_silent("caddy start --config /etc/caddy/Caddyfile")?
}

pub fn (mut i Installer) stop() ? {
	mut node := i.node
	node.exec_silent("caddy stop") or {}
	//TODO: should do some better test to check if caddy is really stopped
}

pub fn (mut i Installer) restart() ? {
	mut node := i.node
	cmd := '
	set +ex
	caddy stop
	set -ex
	caddy start --config /etc/caddy/Caddyfile
	'
	node.exec(cmd)?
}
