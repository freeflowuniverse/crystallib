module main

import freeflowuniverse.crystallib.baobab.hero
import freeflowuniverse.crystallib.osal.gittools

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	mut gs := gittools.get(coderoot: '/tmp/code') or {
		return error("Could not find gittools'\n${err}")
	}

	mut h := hero.new(
		cid: 'acircle'
		gitstructure: gs
		url: 'https://github.com/freeflowuniverse/crystallib/tree/development/examples/cli/hero'
	)!

	h.run()!
}
