module playcmds

import freeflowuniverse.crystallib.clients.dagu { DAG }
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console
import os

pub fn play_dagu(mut plbook playbook.PlayBook) ! {

	dagu_actions := plbook.find(filter: 'dagu.')!
	if dagu_actions.len == 0 {
		return
	}
	

	play_dagu_basic(mut plbook)!
	//play_dagu_configure(mut plbook)!
}


// play_dagu plays the dagu play commands
pub fn play_dagu_basic(mut plbook playbook.PlayBook) ! {

	
	mut install_actions := plbook.find(filter: 'dagu.install')!

	if install_actions.len > 0 {
		for install_action in install_actions {
			mut p := install_action.params
			homedir := p.get_default('homedir', '${os.home_dir()}/hero/var/dagu')!
			configpath := p.get_default('configpath', '${os.home_dir()}/hero/cfg/dagu.yaml')!
			username := p.get_default('username', '')!
			password := p.get_default('password', '')!
			secret := p.get_default('secret', '')!
			title := p.get_default('title', 'My Hero DAG')!
			reset := p.get_default_false('reset')
			start := p.get_default_true('start')
			stop := p.get_default_false('stop')
			restart := p.get_default_false('restart')
			ipaddr := p.get_default('ipaddr', '')!
			port := p.get_int_default('port', 8888)!

			daguinstaller.install(
				homedir: homedir
				configpath: configpath
				username: username
				password: password
				secret: secret
				title: title
				reset: reset
				start: start
				stop:stop
				restart: restart
				ipaddr: ipaddr
				port: port
			)!
		}
	}

	dagu_actions := plbook.find(filter: 'dagu.configure')!
	if dagu_actions.len == 0 {
		return
	}
	
	mut config_actions := plbook.find(filter: 'dagu.configure')!
	mut d := if config_actions.len > 1 {
		return error('can only have 1 config action for dagu')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		instance := p.get_default('instance', 'default')!
		port := p.get_int_default('port', 8888)!
		username := p.get_default('username', '')!
		password := p.get_default('password', '')!
		config_actions[0].done = true
		mut server := daguserver.configure(instance,
			port: port
			username: username
			password: password

		)!
		server.start()!
		console.print_debug('Dagu server is running at http://localhost:${port}')
		console.print_debug('Username: ${username} password: ${password}')
		
		// configure dagu client with server url and api secret
		server_cfg := server.config()!
		dagu.get(instance, 
			url: 'http://localhost:${port}'
			apisecret: server_cfg.secret
		)!
	} else {
		mut server := daguserver.get('')!
		server.start()!
		dagu.get('')!
	}

	mut dags := map[string]DAG{}

	for mut action in plbook.find(filter: 'dagu.new_dag')! {
		mut p := action.params
		name := p.get_default('name', '')!
		dags[name] = DAG{}
		action.done = true
	}

	for mut action in plbook.find(filter: 'dagu.add_step')! {
		mut p := action.params
		dag := p.get_default('dag', 'default')!
		name := p.get_default('name', 'default')!
		command := p.get_default('command', '')!
		dags[dag].step_add(
			nr: dags.len
			name: name
			command: command
		)!
	}

	for mut action in plbook.find(filter: 'dagu.run')! {
		mut p := action.params
		dag := p.get_default('dag', 'default')!
		d.new_dag(dags[dag])!
	}
}
