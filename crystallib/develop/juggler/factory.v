module juggler

import os
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.develop.gittools
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

	j.triggers = j.parse_automations(cfg.config_path)!
	return &j
}

fn (j Juggler) parse_automations(config_path string) !map[string]Trigger {
	mut config_dir := pathlib.get_dir(path: config_path)!
	list := config_dir.list() or {panic(err)}
	repo_paths := list.paths.filter(it.path.trim_string_left(config_path).count('/') == 4)
	
	mut automations := map[string]Trigger
	for path in repo_paths {
		relpath := path.path.trim_string_left(config_dir.path)
		automations[relpath] = Trigger{
			// name: '${relpath.all_after('/').all_after('/')} git CI/CD'
			script: j.load_script(path)
			// description: 'Git webhook CI/CD for ${relpath}'
			event: Event{
				repository: Repository{
					host: relpath.split('/')[0]
					owner: relpath.split('/')[1]
					name: relpath.split('/')[2]
					branch: relpath.split('/')[3]
				}
			}
		}
	}
	return automations
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

// get_repo_playbook returns the CI/CD playbook for a given repository
fn (j Juggler) get_script(args Repository) ?Script {
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
		path: '${repo_cicd_dir.path}/default'
	) or { panic('this should never happen') }
	
	// use default dag if no branch dag specified
	mut branch_dir := pathlib.get_dir(
		path: '${repo_cicd_dir.path}/${args.branch}'
	) or { panic('this should never happen') }
	
	// use branch's own playbook if defined, else use the one for the repo
	return if branch_dir.exists() {
		Script{path:branch_dir}
	} else if default_dir.exists() {
		Script{path:default_dir}
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
