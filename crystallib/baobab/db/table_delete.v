module db

fn table_delete(mut db DB, args DBDeleteArgs) ! {
	name := table_name(db, args.objtype)
	mut statement := table_delete_statement(name, args)
	db.sqlitedb.exec(statement)!

	statement = table_delete_statement('data', args)
	db.sqlitedb.exec(statement)!
}

fn table_delete_statement(name string, args DBDeleteArgs) string {
	return 'DELETE from ${name} WHERE cid = ${args.gid.cid.u32()} AND oid = ${args.gid.oid()}'
}
