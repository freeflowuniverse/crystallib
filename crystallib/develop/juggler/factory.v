module juggler

import os
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.baobab.actor
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.daguserver

pub fn get(j Juggler) !&Juggler {
	// get so is also installed
	mut c := caddy.get(j.name)!
	mut d := daguserver.get(j.name)!
	return &Juggler{
		...j
	}
}

pub struct Config {
mut:
	name string
	url      string
	reset    bool
	pull     bool
	port int
	host string
	coderoot string
	username string
	password string
	config_path string
	config_url string
	secret string
}

pub fn configure(cfg Config) !&Juggler {
	// repo_dir := pathlib.get_dir(path: code_get(cfg)!)!
	mut config_dir := pathlib.get_dir(path: cfg.config_path)!

	config_script := pathlib.get_file(path: '${config_dir.path}/config.hero')!

	// start caddyserver
	mut c := caddy.configure('juggler')!

	// start caddyserver
	mut d := daguserver.configure('juggler',
		username: 'admin'
		password: 'planet1st'
		port: 8888
	)!

	mut j := Juggler {
		Actor: actor.new(
			name: 'admin'
			secret: 'planetfirst'
		)!
		name: cfg.name
		url: cfg.url
		port: cfg.port
		host: cfg.host
		username: cfg.username
		password: cfg.password
		secret: cfg.secret
		config_path: cfg.config_path
		config_url: cfg.config_url
	}

	if cfg.reset {
		j.backend.reset()!
	}

	j.triggers = j.parse_triggers(cfg.config_path)!
	j.scripts = j.load_scripts()!
	return &j
}


fn (mut j Juggler) parse_triggers(config_path string) !map[string]Trigger {
	mut config_dir := pathlib.get_dir(path: config_path)!
	list := config_dir.list() or {panic(err)}
	repo_paths := list.paths.filter(it.path.trim_string_left(config_path).count('/') == 4)
	
	mut triggers := map[string]Trigger
	for path in repo_paths {
		relpath := path.path.trim_string_left(config_dir.path).trim('/')
		mut repo :=  Repository{
			host: relpath.split('/')[0]
			owner: relpath.split('/')[1]
			name: relpath.split('/')[2]
			branch: relpath.split('/')[3]
		}
		if repo.host == 'github' {
			repo.host = 'github.com'
		}
		script_id := j.new_script_from_path(path)!
		repo_id := j.new_repository(repo)!
		git_trigger := Trigger{
			name: 'git push ${repo.name} [${repo.branch}]'
			description: 'git push ${repo.name} [${repo.branch}]'
			object_id: repo_id
			script_ids: [script_id]
		}
		j.new_trigger(git_trigger)!
	}
	return triggers
}

// get_repo_playbook returns the CI/CD playbook for a given repository
fn (j Juggler) get_playbook_dir(args Repository) ?pathlib.Path {
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
	
	// use default dag if no branch dag specified
	mut default_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/${args.branch}/default'
	) or { panic('this should never happen') }
	
	// use default dag if no branch dag specified
	mut branch_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/${args.branch}'
	) or { panic('this should never happen') }
	
	// use branch's own playbook if defined, else use the one for the repo
	return if branch_dir.exists() {
		branch_dir
	} else if default_dir.exists() {
		default_dir
	} else {none}
}

// get_script gets the script to be run by an event
fn (mut j Juggler) get_script(event Event) ?Script {
	// if event !is GitEvent { panic('implement') }

	repo := j.backend.get[Repository](event.object_id) or {panic('this hopefully doesnt happen')}

	if repo.host == '' {panic('this should never happen')}
	
	host := if repo.host == 'github.com' {
		'github'
	} else {repo.host}
	
	cicd_dir := pathlib.get_dir(path: j.config_path) or { 
		panic('this should never happen, juggler configuration gone wrong') 
	}
	
	mut repo_cicd_dir := pathlib.get_dir(
		path: '${cicd_dir.path}/${host}/${repo.owner}/${repo.name}'
	) or { panic('this should never happen') }
	
	// use default dag if no branch dag specified
	mut default_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/default'
	) or { panic('this should never happen') }
	
	// use default dag if no branch dag specified
	mut branch_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/${repo.branch}'
	) or { panic('this should never happen') }
	
	// use branch's own playbook if defined, else use the one for the repo
	return if branch_dir.exists() {
		Script{path:branch_dir.path}
	} else if default_dir.exists() {
		Script{path:default_dir.path}
	} else {none}
}

// returns the path of the fetched repo
fn code_get(cfg Config) !string {
	mut args := cfg

	if 'CODEROOT' in os.environ() && args.coderoot == '' {
		args.coderoot = os.environ()['CODEROOT']
	}

	if args.coderoot.len > 0 {
		// panic('coderoot >0 not supported yet, not imeplemented.')
	}

	mut gs := gittools.get(coderoot: args.coderoot)!
	if args.url.len > 0 {
		return gs.code_get(
			pull: cfg.pull
			reset: cfg.reset
			url: cfg.url
			reload: true
		)!
	}

	return error('URL must be provided to configure juggler')
}
