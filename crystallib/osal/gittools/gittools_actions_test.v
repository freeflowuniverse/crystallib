module gittools

import freeflowuniverse.crystallib.data.actionsparser
import os

const (
	git_do_action  = "
!!gittools.git_do
	coderoot: '${os.home_dir()}/code'
	repo: 'crystallib'
	account: 'freeflowuniverse'
	provider: 'github'
"
	git_get_action = "
!!gittools.git_get
	coderoot: '${os.home_dir()}/code'
	url: 'https://github.com/freeflowuniverse/crystallib'
	pull: false
	reset: false
"
)

fn test_git_do_action() {
	ap := actions.new(
		text: gittools.git_do_action
	)!

	git_do_action(ap.actions[0])!
	assert true
}

fn test_git_get_action() {
	ap := actions.new(
		text: gittools.git_get_action
	)!

	git_get_action(ap.actions[0])!
	assert true
}
