module main

import os
import freeflowuniverse.crystallib.bizmodel

const testpath = os.dir(@FILE) + '/data'

fn do() ! {
	mut m := bizmodel.new(path: testpath)!
	println('')
	println(m.sheet.wiki(includefilter: ['rev'], name: 'revenue')!)
	println(m.sheet.wiki(includefilter: ['cogs'], name: 'cogs')!)
	println(m.sheet.wiki(includefilter: ['margin'], name: 'margin')!)
}

fn main() {
	do() or { panic(err) }
}
