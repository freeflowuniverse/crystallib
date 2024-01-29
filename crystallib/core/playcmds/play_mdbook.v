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
		if p.exists('install') {
			install = p.get_default_true('install')
		}
		if p.exists('reset') {
			reset = p.get_default_false('reset')
		}
		config_actions[0].done = true
	}

	// mut books := mdbook.new(
	// 	buildroot: buildroot
	// 	publishroot: publishroot
	// 	install: install
	// )!

	// for mut action in session.plbook.find(filter: 'book:define')! {
	// 	mut p := action.params
	// 	name := p.get('name')!
	// 	title := p.get_default('title', name)!
	// 	url := p.get('url')!
	// 	// make sure we know the books
	// 	books.book_new(
	// 		name: name
	// 		url: url
	// 		title: title
	// 	)!
	// 	action.done = true
	// }

	// for mut action in session.plbook.find(filter: 'book:collection_add')! {
	// 	mut p := action.params
	// 	name := p.get('name')!
	// 	book := p.get('book')!
	// 	url := p.get('url')!

	// 	mut book2 := books.get(book)!
	// 	book2.collection_add(name: name, url: url)!
	// 	action.done = true
	// }

	// for mut action in session.plbook.find(filter: 'book:collections_add')! {
	// 	mut p := action.params
	// 	book := p.get('book')!
	// 	url := p.get('url')!

	// 	mut book2 := books.get(book)!
	// 	book2.collections_add(git_url: url)!
	// 	action.done = true
	// }

	// mut init_done := false
	// for mut action in session.plbook.find_max_one(filter: 'books:pull')! {
	// 	books.pull(reset)!
	// 	action.done = true
	// 	init_done = true
	// }

	// for mut action in session.plbook.find(filter: 'books:generate')! {
	// 	mut p := action.params
	// 	mut pull2 := p.get_default_false('pull')
	// 	if pull2 {
	// 		books.pull(reset)!
	// 	}
	// 	mut name := p.get_default('name', '')!
	// 	if name.contains(',') {
	// 		names := texttools.to_array(name)
	// 		for name2 in names {
	// 			mut book2 := mdbook.new_from_config(
	// 				books: &books
	// 				instance: name2
	// 				reset: reset
	// 				context: &session.context
	// 			)!
	// 			book2.generate()!
	// 		}
	// 	} else if name == '' {
	// 		for mut book2 in books.books {
	// 			book2.generate()!
	// 			mdbook.save_to_config(*book2, mut session.context)!
	// 		}
	// 	} else {
	// 		mut book2 := mdbook.new_from_config(
	// 			books: &books
	// 			instance: name
	// 			reset: reset
	// 			context: &session.context
	// 		)!
	// 		book2.generate()!
	// 		mdbook.save_to_config(*book2, mut session.context)!
	// 	}
	// 	action.done = true
	// }

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
