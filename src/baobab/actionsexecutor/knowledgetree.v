module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.knowledgetree

fn knowledgetree(mut actions actions.Actions, action actions.Action) ! {
	if action.name == 'scan' {
		mut name := action.params.get_default('name', 'default')!

		knowledgetree.new(name: name)!

		mut path := action.params.get_default('path', '')!
		mut heal := action.params.get_default_false('heal')
		mut load := action.params.get_default_true('load')
		mut git_url := action.params.get_default('git_url', '')!
		mut git_reset := action.params.get_default_false('git_reset')
		mut git_root := action.params.get_default('git_root', '')!
		mut git_pull := action.params.get_default_false('git_pull')

		knowledgetree.scan(
			name: name
			path: path
			heal: heal
			load: load
			git_url: git_url
			git_reset: git_reset
			git_root: git_root
			git_pull: git_pull
		)!
	}

	if action.name == 'mdbook' {
		mut name := action.params.get('name')!
		mut tree_name := action.params.get('tree_name')!

		knowledgetree.new(name: name)!

		mut path := action.params.get_default('path', '')!
		mut git_url := action.params.get_default('git_url', '')!
		mut git_reset := action.params.get_default_false('git_reset')
		mut git_root := action.params.get_default('git_root', '')!
		mut git_pull := action.params.get_default_false('git_pull')
		mut dest := action.params.get('dest')!
		mut dest_md := action.params.get('dest_md')!

		// populate the book and export
		knowledgetree.book_create(
			tree_name: tree_name
			name: name
			path: path
			git_url: git_url
			git_reset: git_reset
			git_root: git_root
			git_pull: git_pull
			dest: dest
			dest_md: dest_md
		)!
	}
}
