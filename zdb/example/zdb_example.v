module main

import freeflowuniverse.crystallib.zdb

fn do() ! {
	mut zdb := zdb.get('~/.zdb/socket', '1234', 'test')!
	i := zdb.nsinfo('default')!
	println(i)
}

fn main() {
	do() or { panic(err) }
}
