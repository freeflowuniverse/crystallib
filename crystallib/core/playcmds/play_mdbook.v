module playcmds

import freeflowuniverse.crystallib.webtools.mdbook
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.data.doctree

pub fn play_mdbook(mut session base.Session) ! {
	mut buildroot := ''
	mut publishroot := ''
	mut coderoot := ''
	// mut install := false
	mut reset := false
	mut pull := false

	// check if any actions for doctree, if not then nothing to do here
	dtactions := session.plbook.find(filter: 'doctree.')!
	if dtactions.len == 0 {
		return
	}

	mut config_actions := session.plbook.find(filter: 'books:configure')!

	if config_actions.len > 1 {
		return error('can only have 1 config action for books')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		if p.exists('buildroot') {
			buildroot = p.get('buildroot')!
		}
		if p.exists('coderoot') {
			coderoot = p.get('coderoot')!
		}
		if p.exists('publishroot') {
			publishroot = p.get('publishroot')!
		}
		if p.exists('reset') {
			reset = p.get_default_false('reset')
		}
		config_actions[0].done = true
	}

	mut tree := doctree.new(
		name: 'main'
	)!

	for mut action in session.plbook.find(filter: 'doctree:add')! {
		mut p := action.params
		url := p.get_default('url', '')!
		path := p.get_default('path', '')!
		tree.scan(
			path: path
			git_url: url
			git_reset: reset
			git_root: coderoot
			git_pull: pull
		)!
		action.done = true
	}

	for mut action in session.plbook.find(filter: 'book:generate')! {
		mut p := action.params
		name := p.get('name')!
		url := p.get('url')!
		title := p.get_default('title', name)!
		publish_path := p.get_default('publish_path', '')!
		build_path := p.get_default('build_path', '')!

		buildroot_book := '${buildroot}/${name}'
		tree.export(dest: buildroot_book, reset: true)!

		mut mdbooks := mdbook.get(instance: name, session: &session)!

		mut cfg := mdbooks.config()!
		cfg.path_build = buildroot
		cfg.path_publish = publishroot

		mdbooks.generate(
			doctree_path: buildroot_book
			name: name
			title: title
			summary_url: url
			publish_path: publish_path
			build_path: build_path
		)!
		action.done = true
	}
}
