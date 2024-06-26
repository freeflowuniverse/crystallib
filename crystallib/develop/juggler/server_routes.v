module juggler

import math
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
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
import os
import encoding.base64
import time

const jwt_secret = jwt.create_secret()

// This is how endpoints are defined in veb. This is the index route
pub fn (j &Juggler) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/home.html'))
}

pub fn (j &Juggler) scripts(mut ctx Context) veb.Result {
	// scripts := j.load_scripts() or {panic('this should never happen ${error}')}
	return ctx.html($tmpl('./templates/scripts.html'))
}

// This is how endpoints are defined in veb. This is the index route
pub fn (j &Juggler) triggers(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/triggers.html'))
}

// This is how endpoints are defined in veb. This is the index route
pub fn (mut j Juggler) activity(mut ctx Context) veb.Result {
	// println('debugzo1 ${j.plays}')
	// println('debugzo2 ${j.scripts}')
	plays := j.backend.list[Play]() or {
		return ctx.server_error('Unable to list plays ${err}')
	}
	return ctx.html($tmpl('./templates/activity.html'))
}

// // This is how endpoints are defined in veb. This is the index route
// pub fn (j &Juggler) settings(mut ctx Context) veb.Result {
// 	return ctx.html($tmpl('./templates/settings.html'))
// }



// This is how endpoints are defined in veb. This is the index route
@[POST]
pub fn (mut j Juggler) trigger(mut ctx Context) veb.Result {
	// get and register event
	event := j.get_event(ctx.req) or {
		return ctx.request_error('error $err') 
	}

	event_id := j.backend.new[Event](event) or {panic('this shouldnt happen ${err}')}
	j.events[event_id.str()] = event
	triggers := j.get_triggers(event) or {panic('this hopefully wont happen')}

	if triggers.len == 0 {
		return ctx.text('No triggers set for event.')
	}

	scripts := j.get_scripts(triggers[0]) or {panic('hopefully doesnt happen')}

	if scripts.len == 0 {
		return ctx.text('No scripts set for event trigger.')
	}

	script := scripts[0]

	play := Play {
		event_id: event_id
		script_id: script.id()
		output: 'job.output'
		status: .starting
	}
	play_id := j.backend.new[Play](play) or {panic('this shouldnt happen ${err}')}
	j.plays['${play.id()}'] = play

	mut sm := startupmanager.get() or {panic('failed to get sm ${err}')}
	sm.start(
		name: 'juggler_play${play_id}'
		cmd: 'hero run -cr ${os.home_dir()}/code -p ${script.path}'
		restart: false
	) or {panic('failed to start sm ${err}')}

	return ctx.text('DAG "dag.name}" started')
}

	// status := match sm.status('juggler${event.id()}') or {panic('failed to get sm status ${err}')} {
	// 	.activating {Status.running}
	// 	.active {Status.running}
	// 	.deactivating {Status.running}
	// 	.failed {Status.error}
	// 	.inactive {Status.error}
	// 	.unknown {Status.error}
	// }

// @['/repository/:identifier']
// pub fn (mut j Juggler) repository(mut ctx Context, identifier string) veb.Result {
// 	repository := j.repositories[identifier]
	
// 	repo_logs := j.logs.filter(it.trigger.repository.identifier() == identifier)
// 	number_of_deploys := repo_logs.len
// 	sum_time := arrays.sum[i64](repo_logs.map(i64(it.duration))) or {return ctx.server_error('${err}')}
// 	average_time := time.Duration(sum_time / number_of_deploys)
// 	success_rate := repo_logs.filter(it.status == .success).len / number_of_deploys
// 	latest_deployment := repo_logs[repo_logs.len-1].trigger.commit.time.relative_short()

// 	success_rate_str := '${math.round_sig(success_rate*100, 1)}%'
// 	return ctx.html($tmpl('./templates/repository.html'))
// }

// // @['/play2/:identifier']
// // pub fn (mut j Juggler) play2(mut ctx Context, identifier string) veb.Result {
// // 	play := j.plays[identifier]
	
// // 	play_logs := j.plays.filter(it.trigger.repository.identifier() == identifier)
// // 	number_of_plays := play_logs.len
// // 	sum_time := arrays.sum[i64](play_logs.map(i64(it.duration))) or {return ctx.server_error('${err}')}
// // 	average_time := time.Duration(sum_time / number_of_plays)
// // 	success_rate := play_logs.filter(it.status == .success).len / number_of_plays
// // 	latest_play := play_logs[play_logs.len-1].trigger.commit.time.relative_short()

// // 	success_rate_str := '${math.round_sig(success_rate*100, 1)}%'
// // 	return ctx.html($tmpl('./templates/play.html'))
// // }

@['/play/:id']
pub fn (mut j Juggler) play(mut ctx Context, id string) veb.Result {
	mut play := j.backend.get[Play](id.u32()) or {
		println('play with id <${id}> not found')
		return ctx.not_found()}
	
	script := j.scripts[play.script_id]
	trigger := j.scripts[play.trigger_id]
	
	mut event := j.backend.get[Event](play.event_id) or {
		println('event with id <${play.event_id}> not found')
		return ctx.not_found()}

	script_dir := script.path
	
	mut sm := startupmanager.get() or {panic('failed to get sm ${err}')}	
	mut output := sm.output('juggler_play${play.id}') or {panic('failed to get sm output ${err}')} 
	output = output.replace('\n','</br>')

	return ctx.html($tmpl('./templates/play.html'))
}

pub fn (j &Juggler) login(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/login.html'))
}

pub struct LoginForm {}

@[POST; '/login']
pub fn (j &Juggler) login_post(mut ctx Context) veb.Result {
	data := http.parse_form(ctx.req.data)
	username := data['username']
	password := data['password']

	if !(username == 'admin' && password == j.password) {
		return j.login(mut ctx)
	}
	token := jwt.create_token(
		sub: 'admin'
		iss: 'juggler'
	)
	signed_token := token.sign(jwt_secret)
	ctx.set_cookie(name:'access_token', value:signed_token, path:'')
	return j.index(mut ctx)
}

@['/scripts/create']
pub fn (j &Juggler) scripts_create(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/scripts_create.html'))
}