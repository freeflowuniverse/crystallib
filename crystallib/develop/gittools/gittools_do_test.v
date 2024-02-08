module gittools

import freeflowuniverse.crystallib.core.playbook
import os

fn test_git() {
	actionsplaybook := playbook.parse_playbook(
		text: "
		!!gittools.clone
			coderoot: '/tmp/codetest'
			url: 'https://github.com/freeflowuniverse/webcomponents/tree/main'

		!!gittools.clone
			coderoot: '/tmp/codetest'
			url: 'https://github.com/freeflowuniverse/crystallib'

		!!gittools.pull
			coderoot: '/tmp/codetest'
			repo: 'crystallib'
			account: 'freeflowuniverse'
			provider: 'github'			


		!!gittools.push
			coderoot: '/tmp/codetest'
			repo: 'webcomponents'

		!!gittools.list
			coderoot: '/tmp/codetest'

		"
	)!
	println(actionsplaybook)
	actions(actionsplaybook.actions)!
	assert false
}
