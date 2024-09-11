module playcmds

import freeflowuniverse.crystallib.webtools.mdbook
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.playbook
import os

pub fn play_mdbook(mut plbook playbook.PlayBook) ! {
	mut buildroot := '${os.home_dir()}/hero/var/mdbuild'
	mut publishroot := '${os.home_dir()}/hero/www/info'
	mut coderoot := ''
	// mut install := false
	mut reset := false
	mut pull := false

	// check if any actions for doctree, if not then nothing to do here
	dtactions := plbook.find(filter: 'doctree.')!
	// if dtactions.len == 0 {
	// 	console.print_debug("can't find doctree.add statements, nothing to do")
	// 	return
	// }

	mut config_actions := plbook.find(filter: 'books:configure')!

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

	for mut action in plbook.find(filter: 'doctree:add')! {
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

	for mut action in plbook.find(filter: 'book:export')! {
		mut p := action.params
		build_path := p.get('path')!
		reset2 := p.get_default_false('reset')
		production2 := p.get_default_true('production')
		tree.export(dest: build_path, reset: reset2, production: production2)!
		action.done = true
	}

	for mut action in plbook.find(filter: 'book:generate')! {
		mut p := action.params
		name := p.get('name')!
		url := p.get('url')!
		title := p.get_default('title', name)!
		publish_path := p.get_default('publish_path', '${publishroot}/${name}')!
		build_path := p.get_default('build_path', '${buildroot}/${name}')!
		printbook := p.get_default_false('printbook')
		foldlevel := p.get_int_default('foldlevel', 0)!
		production := p.get_default_false('production')

		tree.export(dest: build_path, reset: true)!

		mut mdbooks := mdbook.get()!

		mut cfg := mdbooks.config()!
		cfg.path_build = buildroot
		cfg.path_publish = publishroot

		mdbooks.generate(
			doctree_path: build_path
			name: name
			title: title
			summary_url: url
			publish_path: publish_path
			build_path: build_path
			printbook: printbook
			foldlevel: foldlevel
			production: production
		)!
		action.done = true
	}
}
