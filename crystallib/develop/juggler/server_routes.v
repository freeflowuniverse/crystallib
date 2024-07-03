module juggler

import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.webserver.auth.jwt
import net.http
import veb
import os
import arrays
import time
import math

const jwt_secret = jwt.create_secret()

// This is how endpoints are defined in veb. This is the index route
pub fn (j &Juggler) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/home.html'))
}

pub fn (mut j Juggler) scripts(mut ctx Context) veb.Result {
	scripts := j.backend.list[Script]() or { panic('this should never happen ${error}') }
	return ctx.html($tmpl('./templates/scripts.html'))
}

// This is how endpoints are defined in veb. This is the index route
pub fn (mut j Juggler) triggers(mut ctx Context) veb.Result {
	triggers := j.backend.list[Trigger]() or { panic('this shouldnt happen') }
	return ctx.html($tmpl('./templates/triggers.html'))
}

// This is how endpoints are defined in veb. This is the index route
pub fn (mut j Juggler) activity(mut ctx Context) veb.Result {
	j.update_plays() or { return ctx.server_error('Failed to update play statuses') }
	plays := j.backend.list[Play]() or { return ctx.server_error('Unable to list plays ${err}') }.reverse()
	events := j.backend.list[Event]() or { return ctx.server_error('Unable to list plays ${err}') }
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
	event := j.get_event(ctx.req) or { return ctx.request_error('error ${err}') }

	event_id := j.backend.new[Event](event) or { panic('this shouldnt happen ${err}') }
	triggers := j.get_triggers(event) or { panic('this hopefully wont happen') }

	if triggers.len == 0 {
		return ctx.text('No triggers set for event.')
	}

	scripts := j.get_scripts(triggers[0]) or { panic('hopefully doesnt happen') }

	if scripts.len == 0 {
		return ctx.text('No scripts set for event trigger.')
	}

	for script in scripts {
		play := Play{
			event_id: event_id
			script_id: script.id
			start: time.now()
			trigger_id: triggers[0].id
			output: 'job.output'
			status: .starting
		}
		play_id := j.backend.new[Play](play) or { panic('this shouldnt happen ${err}') }

		mut sm := startupmanager.get() or { panic('failed to get sm ${err}') }
		sm.start(
			name: 'juggler_play${play_id}'
			cmd: 'hero run -cr ${os.home_dir()}/code -p ${script.path}'
			env: {
				'HOME': os.home_dir()
			}
			restart: false
		) or { panic('failed to start sm ${err}') }
	}

	return ctx.text('DAG "dag.name}" started')
}

@['/script/:id']
pub fn (mut j Juggler) script(mut ctx Context, id string) veb.Result {
	mut script := j.backend.get[Script](id.u32()) or {
		return ctx.server_error('script with id <${id}> not found')
	}

	plays := j.backend.list[Play]() or {
		return ctx.server_error('script with id <${id}> not found')
	}

	script_plays := plays.filter(it.script_id == id.u32())

	number_of_deploys := script_plays.len

	sum_time := if script_plays.len > 0 {
		arrays.sum[i64](script_plays.map(i64(it.duration))) or { return ctx.server_error('${err}') }
	} else {
		0
	}

	average_time := if script_plays.len > 0 {
		time.Duration(sum_time / number_of_deploys)
	} else {
		0
	}
	success_rate := if script_plays.len > 0 {
		script_plays.filter(it.status == .success).len / number_of_deploys
	} else {
		0
	}

	latest_deployment := if script_plays.len > 0 {
		script_plays[script_plays.len - 1].start.relative_short()
	} else {
		''
	}

	success_rate_str := '${math.round_sig(success_rate * 100, 1)}%'
	return ctx.html($tmpl('./templates/script.html'))
}

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
		return ctx.server_error('play with id <${id}> not found')
	}

	mut sm := startupmanager.get() or { panic('failed to get sm ${err}') }

	sm_status := sm.status('juggler_play${play.id}') or { panic('failed to get sm status ${err}') }
	play.status = match sm_status {
		.activating { Status.running }
		.active { Status.running }
		.deactivating { Status.running }
		.failed { Status.error }
		.inactive { Status.success }
		.unknown { Status.error }
	}

	status_color := match play.status {
		.starting { 'yellow-500' }
		.success { 'emerald-500' }
		.running { 'amber-500' }
		.error { 'red-500' }
	}

	j.backend.set[Play](play) or { panic(err) }

	script := j.backend.get[Script](play.script_id) or {
		return ctx.server_error('Script with id <${play.script_id}> not found')
	}
	trigger := j.backend.get[Trigger](play.trigger_id) or {
		return ctx.server_error('trigger with id <${play.trigger_id}> not found')
	}
	mut event := j.backend.get[Event](play.event_id) or {
		return ctx.server_error('event with id <${play.event_id}> not found')
	}

	repository := j.backend.get[Repository](event.object_id) or {
		return ctx.server_error('repo with id <${event.object_id}> not found')
	}

	script_dir := script.path

	mut output := sm.output('juggler_play${play.id}') or { panic('failed to get sm output ${err}') }
	output = output.replace('\n', '</br>')

	return ctx.html($tmpl('./templates/play.html'))
}

pub fn (j &Juggler) login(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/login.html'))
}

pub struct LoginForm {}

@['/login'; POST]
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
	signed_token := token.sign(juggler.jwt_secret)
	ctx.set_cookie(name: 'access_token', value: signed_token, path: '')
	return j.index(mut ctx)
}

@['/scripts/create']
pub fn (j &Juggler) scripts_create(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/scripts_create.html'))
}

@['/scripts/create']
pub fn (mut j Juggler) trigger_row(trigger Trigger) string {
	mut scripts := j.backend.list[Script]() or { return '' }
	scripts = scripts.filter(it.id in trigger.script_ids)
	return $tmpl('./templates/trigger_row.html')
}
