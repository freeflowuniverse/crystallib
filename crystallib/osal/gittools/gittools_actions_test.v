module gittools

import freeflowuniverse.crystallib.data.actionparser
import os

fn test_git() {
	actionscollection := actionparser.parse_collection(
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
	println(actionscollection)
	actions(actionscollection.actions)!
	assert false
}
