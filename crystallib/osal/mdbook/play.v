module mdbook

import freeflowuniverse.crystallib.core.play

pub fn play(args play.PlayArgs) ! {
	mut session := play.session(args)!

	mut coderoot := ''
	mut buildroot := ''
	mut publishroot := ''
	mut install := true
	mut reset := false

	//!!books.config 	coderoot:'/tmp/code' install:true reset:true publishroot:'/tmp/publish'
	// DEFAULTS:
	// coderoot    '${os.home_dir()}/hero/code'
	// buildroot   '${os.home_dir()}/hero/var/mdbuild'
	// publishroot '${os.home_dir()}/hero/www/info'
	// install     true
	// reset       false	
	mut configactions := session.actions.find(actor: 'books', name: 'config')!
	if configactions.len > 1 {
		return error('can only have 1 config action for books')
	} else if configactions.len == 1 {
		mut p := configactions[0].params
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
			install = p.get_default_true('install')!
		}
		if p.exists('reset') {
			reset = p.get_default_false('reset')!
		}
	}
	if coderoot == '' {
		coderoot = session.context.coderoot()
	}

	mut books := new(
		coderoot: coderoot
		buildroot: buildroot
		publishroot: publishroot
		install: install
		reset: reset
	)!

	for action in session.actions.find(actor: 'books', name: 'new') {
		mut p := action.params
		name := p.get('name')!
		title := p.get_default('title', name)!
		url := p.get('url')!
		// make sure we know the books
		mybooks.book_new(
			name: name
			url: url
			title: title
		)!
	}

	for action in session.actions.find(actor: 'books', name: 'playbook_add') {
		mut p := action.params
		name := p.get('name')!
		book := p.get('book')!
		url := p.get('url')!

		mut book2 := books.get(book)!
		book2.playbook_add(name: name, url: url)!
	}
}
