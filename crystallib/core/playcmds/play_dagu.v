module playcmds

import freeflowuniverse.crystallib.clients.dagu { DAG }
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.core.playbook

// play_dagu plays the dagu play commands
pub fn play_dagu(mut plbook playbook.PlayBook) ! {
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
		_ := daguserver.configure(instance,
			port: port
			username: username
			password: password
		)!
		dagu.get(instance, url: 'http://localhost:${port}')!
	} else {
		_ := daguserver.get('')!
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
