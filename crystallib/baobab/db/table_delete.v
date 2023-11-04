module db

import freeflowuniverse.crystallib.baobab.smartid

fn table_delete(mut db DB, args DBDeleteArgs) ! {
	mut statement := table_delete_statement(table_name_find(db), args)
	db.sqlitedb.exec(statement)!

	statement = table_delete_statement(table_name_data(db), args)
	db.sqlitedb.exec(statement)!
}

fn table_delete_statement(name string, args DBDeleteArgs) string {
	gid := args.gid or { smartid.GID{} }
	oid := gid.oid()
	q := if oid > 0 {
		'DELETE from ${name} WHERE oid = ${oid}'
	} else {
		'DELETE * from ${name}'
	}
	return q
}
