module play

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.osal.gittools

fn (mut context Context) actions_execute(mut plbook playbook.PlayBook) ! {
	for mut action in plbook.find(actor: 'core', name: 'context_set')! {
		mut p := action.params
		if p.exists('name') || context.name == '' {
			context.name = p.get_default('name', 'default')!
		}
		if p.exists('cid') || context.cid == '' {
			context.cid = p.get_default('cid', '000')!
		}
		if p.exists('interactive') {
			context.fsdb_context.config.interactive = p.get_default_false('interactive')
		}
		if p.exists('fsdb_encryption') {
			context.fsdb_context.config.encryption = p.get_default_false('fsdb_encryption')
		}
		if p.exists('coderoot') {
			mut coderoot := p.get_path('coderoot')!
			if context.gitstructure.rootpath.path != coderoot {
				mut gs := gittools.get(coderoot: coderoot)!
				context.gitstructure = &gs
			}
		}
		action.done = true
	}

	for mut action in plbook.find(actor: 'core', name: 'coderoot_set')! {
		mut p := action.params
		if p.exists('coderoot') {
			coderoot := p.get_path('coderoot')!
			if context.coderoot() != coderoot {
				mut gs := gittools.get(coderoot: coderoot)!
				context.gitstructure = &gs
			}
		}else{
			return error("coderoot needs to be specified")
		}
		action.done = true
	}

	// !!core.snippet snippetname:codeargs pull:true reset:false
	for mut action in plbook.find(actor: 'core', name: 'snippet')! {
		mut p := action.params

		panic("implement")

		snippetname := p.get('snippetname')!
		p.delete("snippetname")

		context.snippets[snippetname]=p

		action.done = true
	}

	for action in plbook.find(actor: 'core', name: 'params_context_set')! {
		mut p := action.params
		for param in p.params{
			context.params.set(param.key,param.value)
		}
	}
}

fn (mut session Session) actions_execute(mut plbook playbook.PlayBook) ! {
	for action in plbook.find(actor: 'core', name: 'params_session_set')! {
		mut p := action.params
		for param in p.params{
			session.params.set(param.key,param.value)
		}
	}
}
