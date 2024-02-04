module playcmds

import freeflowuniverse.crystallib.osal.mdbook
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.play

pub fn play_mdbook(mut session play.Session) ! {
	mut coderoot := ''
	mut buildroot := ''
	mut publishroot := ''
	mut install := false
	mut reset := false
	mut pull := false

	mut config_actions := session.plbook.find(filter: 'books:configure')!

	if config_actions.len > 1 {
		return error('can only have 1 config action for books')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		if p.exists('coderoot') {
			coderoot = p.get('coderoot')!
		}
		if p.exists('buildroot') {
			buildroot = p.get('buildroot')!
		}
		if p.exists('publishroot') {
			publishroot = p.get('publishroot')!
		}
		if p.exists('reset') {
			reset = p.get_default_false('reset')
		}
		config_actions[0].done = true
	}


	mdbookinstaller.install()!

	if coderoot.len>0{
		session.coderoot=coderoot
		context_name = "othercoderoot"
	}

	mut tree := doctree.tree_create(name: 'main')!

	for mut action in session.plbook.find(filter: 'doctree:add')! {
		mut p := action.params
		url := p.get('url')!
		tree.scan(git_url: url)!
		action.done = true
	}

	tree.export(dest:buildroot,reset:true)!

	for mut action in session.plbook.find(filter: 'book:generate')! {
		mut p := action.params
		name := p.get('name')!
		title := p.get_default('title', name)!
		url := p.get('url')!
		mut mdbook_factory := mdbook.new(session:session)!
		mut mybook := mdbook_factory.generate(doctree_path:buildroot,name:name,title:title,summary_url:url)!
		action.done = true
	}



	// for mut action in session.plbook.find(filter:'book:edit')! {
	// 	mut p := action.params
	// 	mut name := p.get('name')!
	// 	mut book2 := books.get(name)!
	// 	book2.edit()!
	// 	action.done=true
	// }

	// for mut action in session.plbook.find(filter:'book:open')! {
	// 	mut p := action.params
	// 	mut name := p.get('name')!
	// 	mut book2 := books.get(name)!
	// 	book2.open()!
	// 	action.done=true
	// }
}
