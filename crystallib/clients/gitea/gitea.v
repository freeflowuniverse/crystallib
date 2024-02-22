module gitea

// import os
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.core.play
import os

struct GiteaClient[T] {
	play.Base[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

pub struct Config {
	play.ConfigBase
pub:
	configtype string = 'gitea_client' //needs to be defined
pub mut:
	url string
	username string
	password string
}

//
pub fn get(args play.PlayArgs) !GiteaClient[Config] {
	mut client := GiteaClient[Config]{
		instance: args.instance
		connection: httpconnection.new(
			name: 'gitea'
			url: 'https://git.ourworld.tf/api/v1'
		)!
	}

	client.init(args)!
	client.config_save()!
	config := client.config()!
	return client
}
//
pub fn heroplay(args play.PLayBookAddArgs) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'gitea_client.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		mut config := p.decode[Config]()!
		cl.config_save()!
	}
}