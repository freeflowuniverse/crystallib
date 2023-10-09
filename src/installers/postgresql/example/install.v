module main

import freeflowuniverse.crystallib.installers.postgresql

fn do() ! {
	mut db := postgresql.new(passwd: '12', reset: true)!
	db.db_create('works')!
}

fn main() {
	do() or { panic(err) }
}
