module playcmds

// import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook

// !!context.configure
//     name:'test'
//     coderoot:...
//     interactive:true

pub fn play_core(mut plbook playbook.PlayBook) ! {
	for mut action in plbook.find(filter: 'context.configure')! {
		mut p := action.params
		mut session:=plbook.session
		// if p.exists('name') || session.context.name == '' {
		// 	session.context.name = p.get_default('name', 'default')!
		// }
		// if p.exists('cid') || session.context.cid == '' {
		// 	session.context.cid = p.get_default('cid', '000')!
		// }
		if p.exists('interactive') {
			session.interactive = p.get_default_false('interactive')
		}
		// if p.exists('fsdb_encrypted') {
		// 	session.context.contextdb.encrypted = p.get_default_false('fsdb_encrypted')
		// }
		if p.exists('coderoot') {
			mut coderoot := p.get_path_create('coderoot')!
			mut gs := session.context.gitstructure()!
			if gs.rootpath.path != coderoot {
				mut db := session.context.dbcollection.get('context')!
				db.set('coderoot', coderoot)!
				session.context.gitstructure_reload()!
			}
		}
		action.done = true
	}

	// for mut action in plbook.find(filter: 'core.coderoot_set')! {
	// 	mut p := action.params
	// 	if p.exists('coderoot') {
	// 		coderoot := p.get_path_create('coderoot')!
	// 		mut gs := session.context.gitstructure()!
	// 		if gs.rootpath.path != coderoot {
	// 			mut db := session.context.contextdb.db_get(dbname: 'context')!
	// 			db.set('coderoot', coderoot)!
	// 			session.context.gitstructure_reload()!
	// 		}
	// 	} else {
	// 		return error('coderoot needs to be specified')
	// 	}
	// 	action.done = true
	// }

	// for mut action in plbook.find(filter: 'core.params_context_set')! {
	// 	mut p := action.params
	// 	for param in p.params {
	// 		session.context.params.set(param.key, param.value)
	// 	}
	// 	action.done = true
	// }

	// for mut action in plbook.find(filter: 'core.params_session_set')! {
	// 	mut p := action.params
	// 	for param in p.params {
	// 		session.params.set(param.key, param.value)
	// 	}
	// 	action.done = true
	// }
}
