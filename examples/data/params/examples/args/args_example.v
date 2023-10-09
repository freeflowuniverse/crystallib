module main

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.params
import os

const testpath = os.dir(@FILE) + '/data'

fn do() ! {
	ap := actions.new(path: testpath, defaultcircle: 'default')!

	mut test := map[string]string{}
	test['root'] = 'YEH'
	test['roott'] = 'YEH2'
	for action in ap.actions {
		// action.params.replace(test)
		mut p := action.params
		p.replace(test)
		println(p)
	}

	txt := '

	this is a text \${aVAR}

	this is a text \${aVAR}

	\${A}

	'
	// println(txt)
	// println(params.regexfind(txt))
}

fn main() {
	do() or { panic(err) }
}
