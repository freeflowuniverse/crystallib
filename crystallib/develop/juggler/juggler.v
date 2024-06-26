module juggler

import math
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.clients.dagu { DAG }
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.webserver.auth.jwt { SignedJWT }
import arrays
import net.http
import veb
import json
import encoding.base64
import time

import freeflowuniverse.crystallib.baobab.actor

// Juggler is a Continuous Integration Juggler that listens for triggers from gitea repositories.
pub struct Juggler {
	actor.Actor
	veb.StaticHandler
	veb.Middleware[Context]
pub:
	name string
	host string
	port int
	username string
	password string
	secret string
	config_path string
	url string
	repo_path string // local path to the itenv repository defining dag's per repos
	dagu_url  string // url of the dagu server the ci/cd will be triggered at
pub mut:
	is_authenticated bool
	plays map[string]Play
	triggers map[string]Trigger
	events map[string]Event
	repositories map[string]Repository
	scripts map[string]Script
	// plays map[string]Play
	config_url string
}

// get_repo_playbook returns the CI/CD playbook for a given repository
fn (j Juggler) get_repo_playbook(args Repository) ?playbook.PlayBook {
	if args.host == '' {panic('this should never happen')}
	
	host := if args.host == 'github.com' {
		'github'
	} else {args.host}
	
	cicd_dir := pathlib.get_dir(path: j.config_path) or { 
		panic('this should never happen, juggler configuration gone wrong') 
	}
	
	mut repo_cicd_dir := pathlib.get_dir(
		path: '${cicd_dir.path}/${host}/${args.owner}/${args.name}'
	) or { panic('this should never happen') }
	
	if !repo_cicd_dir.exists() {
		return none
	}

	// use default dag if no branch dag specified
	mut branch_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/${args.branch}'
	) or { panic('this should never happen') }

	// use branch's own playbook if defined, else use the one for the repo
	pb := if branch_dir.exists() {
		playbook.new(path: branch_dir.path) or {panic('this should never happen')}
	} else {
		playbook.new(path: repo_cicd_dir.path) or {panic('this should never happen')}
	}

	return pb
}

pub fn (j Juggler) open() ! {
	cmd := 'open ${j.dagu_url}'
	osal.exec(cmd: cmd)!
}

pub fn (j Juggler) info() string {
	mut str := '=============== Juggler ===============\n\n'
	str += 'User Interface:\n- url: http://${j.host}:${j.port}\n- status: running\n'
	str += '\nWebhook:\n- enpoint: ${j.host}:${j.port}/trigger\n- secret: ${j.secret}\n'
	str += '\n======================================='
	return str
}

pub fn (j Juggler) load_scripts() !map[string]Script {
	mut scripts := map[string]Script{}

	mut config_dir := pathlib.get_dir(path:j.config_path) or {panic(err)}
	list := config_dir.list() or {panic(err)}
	
	script_paths := list.paths.filter(it.path.trim_string_left(j.config_path).count('/') == 4)

	for path in script_paths {
		script := j.load_script(path)!
		scripts[script.id()] = script
	}
	return scripts
}

pub fn (mut j Juggler) get_triggers(e Event) ![]Trigger {
	triggers := j.backend.list[Trigger]()!
	println("debugzo123 ${triggers}")
	return triggers.filter(j.is_triggered(it, e))
}


pub fn (mut j Juggler) get_scripts(t Trigger) ![]Script {
	scripts := j.backend.list[Script]()!
	mut triggered_scripts := []Script{}
	for _, script in scripts {
		if script.id in t.script_ids {
			triggered_scripts << script
		}
	}
	return triggered_scripts
}

// pub fn (mut j Juggler) get_script_from_path(path_ pathlib.Path) !Script {
// 	scripts := j.backend.list[Script]()!
// 	script_lst := scripts.filter(it.path.path == path_.path) 

// 	println('debugzoni ${script_lst}')
// 	if script_lst.len < 1 {
// 		return error('no script found for path')
// 	}

// 	return script_lst[0]
// }

pub fn (j Juggler) load_script(path_ pathlib.Path) !Script {
	mut path := pathlib.get(path_.path)
	mut readme_file := pathlib.get_file(path: '${path.path}/README.md')!
	
	relpath := path.path.trim_string_left(j.config_path)
	name := if readme_file.exists() {
		readme_doc := markdownparser.new(path:readme_file.path)!
		readme_doc.header_name()!
	} else {
		relpath.all_after('/').all_after('/')
	}

	description := if readme_file.exists() {
		readme_doc := markdownparser.new(path:readme_file.path)!
		paragraph := readme_doc.children[2]
		// TODO: more defensive
		paragraph.children[0].content.trim_space()
	} else {''}

	mut paths := path.list()!.paths.clone()

	mut category := ScriptCategory.hero
	if paths.any(it.extension() == 'bash' || it.extension() == 'sh') {
		category = ScriptCategory.shell
	} else if paths.any(it.extension() == 'v' || it.extension() == 'vsh') {
		ScriptCategory.vlang
	}

	return Script {
		name: name
		category: category
		description: description
		url: '${j.config_url}/${relpath}'
		path: path.path
	}
}

pub fn (mut j Juggler) new_script_from_path(path_ pathlib.Path) !u32 {
	mut path := pathlib.get(path_.path)
	mut readme_file := pathlib.get_file(path: '${path.path}/README.md')!
	
	relpath := path.path.trim_string_left(j.config_path)
	name := if readme_file.exists() {
		readme_doc := markdownparser.new(path:readme_file.path)!
		readme_doc.header_name()!
	} else {
		relpath.all_after('/').all_after('/')
	}

	description := if readme_file.exists() {
		readme_doc := markdownparser.new(path:readme_file.path)!
		paragraph := readme_doc.children[2]
		// TODO: more defensive
		paragraph.children[0].content.trim_space()
	} else {''}

	mut paths := path.list()!.paths.clone()

	mut category := ScriptCategory.hero
	if paths.any(it.extension() == 'bash' || it.extension() == 'sh') {
		category = ScriptCategory.shell
	} else if paths.any(it.extension() == 'v' || it.extension() == 'vsh') {
		ScriptCategory.vlang
	}

	script := Script {
		name: name
		category: category
		description: description
		url: '${j.config_url}/${relpath}'
		path: path.path
	}

	return j.backend.new[Script](script)!
}

pub enum ScriptCategory {
	hero
	vlang
	shell
}