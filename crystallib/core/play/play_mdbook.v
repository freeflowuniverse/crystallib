module play

import freeflowuniverse.crystallib.osal.mdbook

pub fn (mut session Session) play_mdbook() ! {

	mut coderoot:=""
	mut buildroot:=""
	mut publishroot:=""
	mut install:=false
	mut reset:=false

	mut config_actions := session.plbook.find(filter:'books:config')!
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
	}
	if coderoot == '' {
		coderoot = session.context.coderoot()
	}

	mut books := mdbook.new(
		coderoot: coderoot
		buildroot: buildroot
		publishroot: publishroot
		install: install
		reset: reset
	)!

	for action in session.plbook.find(filter:'books:new')!{
		mut p := action.params
		name := p.get('name')!
		title := p.get_default('title', name)!
		url := p.get('url')!
		// make sure we know the books
		books.book_new(
			name: name
			url: url
			title: title
		)!
	}


	for action in session.plbook.find(filter:'books:collection_add')! {
		mut p := action.params
		name := p.get('name')!
		book := p.get('book')!
		url := p.get('url')!

		mut book2 := books.get(book)!
		book2.collection_add(name: name, url: url)!
	}
}
