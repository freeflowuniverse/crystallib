module juggler

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.clients.dagu { DAG }
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.servers.caddy
import veb
import json

// Juggler is a Continuous Integration Juggler that listens for triggers from gitea repositories.
pub struct Juggler {
	name string
	repo_path string // local path to the itenv repository defining dag's per repos
	dagu_url  string // url of the dagu server the ci/cd will be triggered at
}

pub struct Context {
	veb.Context
}

pub fn (mut j Juggler) run(port int) ! {
	mut c := caddy.get(j.name)!
	c.start()!
	
	mut d := daguserver.get(j.name)!
	d.start()!

	veb.run[Juggler, Context](mut j, port)
}

// This is how endpoints are defined in veb. This is the index route
pub fn (j &Juggler) index(mut ctx Context) veb.Result {
	return ctx.text('Hello V!')
}

// This is how endpoints are defined in veb. This is the index route
@[POST]
pub fn (j &Juggler) trigger(mut ctx Context) veb.Result {
	data := ctx.req.data
	event := json.decode(Event, data) or { panic(err) }

	script := j.get_repo_playbook(event) or { return ctx.text('no dag found for repo') }

	// mut dagu_client := dagu.get('default',
	//     url: j.dagu_url
	// ) or {panic(err)}

	// dagu_client.new_dag(dag, overwrite: true) or {
	//     return ctx.text('error creating dag ${err}')
	// }

	mut pb := j.get_repo_playbook(event) or { return ctx.text('no script found for repo') }
	playcmds.play_dagu(mut pb) or {panic(err)}

	return ctx.text('DAG "dag.name}" started')
}

// get_repo_playbook returns the CI/CD playbook for a given repository
fn (j Juggler) get_repo_playbook(e Event) ?playbook.PlayBook {
	cicd_dir := pathlib.get_dir(path: j.repo_path) or { panic('this should never happen') }
	mut repo_cicd_dir := pathlib.get_dir(
		path: '${cicd_dir.path}/git.ourworld.tf/${e.repository.full_name}'
	) or { panic('this should never happen') }

	if !repo_cicd_dir.exists() {
		return none
	}

	panic('implement')
	// // QUESTION: DAG PER ORGANIZATION?

	// // use default dag if no branch dag specified
	// branch_name := e.ref.all_after_last('/')
	// mut branch_dag := pathlib.get_file(
	// 	path: '${repo_cicd_dir.path}/${branch_name}/dag.json'
	// ) or { panic('this should never happen') }

	// mut dag_file := if branch_dag.exists() {
	// 	branch_dag
	// } else {
	// 	pathlib.get_file(
	// 		path: '${repo_cicd_dir.path}/dag.json'
	// 	) or { panic('this should never happen') }
	// }

	// if !dag_file.exists() {
	// 	return none
	// }
	// dag_json := dag_file.read() or { panic('this should never happen') }
	// return json.decode(DAG, dag_json) or { panic('failed to decode ${err}') }
}

pub fn (j Juggler) open() ! {
	cmd := 'open ${j.dagu_url}'
	osal.exec(cmd: cmd)!
}
