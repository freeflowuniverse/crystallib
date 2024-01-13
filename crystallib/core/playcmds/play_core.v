module playcmds

// import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.play

pub fn play_core(mut session play.Session) ! {
	mut t := session.plbook.find(filter: 'core.context_set')!
	for mut action in session.plbook.find(filter: 'core.context_set')! {
		mut p := action.params
		if p.exists('name') || session.context.name == '' {
			session.context.name = p.get_default('name', 'default')!
		}
		if p.exists('cid') || session.context.cid == '' {
			session.context.cid = p.get_default('cid', '000')!
		}
		if p.exists('interactive') {
			session.context.kvs.config.interactive = p.get_default_false('interactive')
		}
		if p.exists('fsdb_encryption') {
			session.context.kvs.config.encryption = p.get_default_false('fsdb_encryption')
		}
		if p.exists('coderoot') {
			mut coderoot := p.get_path_create('coderoot')!
			if session.context.gitstructure.rootpath.path != coderoot {
				mut gs := gittools.get(coderoot: coderoot)!
				session.context.gitstructure = &gs
			}
		}
		action.done = true
	}

	for mut action in session.plbook.find(filter: 'core.coderoot_set')! {
		mut p := action.params
		if p.exists('coderoot') {
			coderoot := p.get_path_create('coderoot')!
			if session.context.coderoot() != coderoot {
				mut gs := gittools.get(coderoot: coderoot)!
				session.context.gitstructure = &gs
			}
		} else {
			return error('coderoot needs to be specified')
		}
		action.done = true
	}

	for mut action in session.plbook.find(filter: 'core.params_context_set')! {
		mut p := action.params
		for param in p.params {
			session.context.params.set(param.key, param.value)
		}
		action.done = true
	}

	for mut action in session.plbook.find(filter: 'core.params_session_set')! {
		mut p := action.params
		for param in p.params {
			session.params.set(param.key, param.value)
		}
		action.done = true
	}
}
