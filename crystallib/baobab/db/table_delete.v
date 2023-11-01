module db
import freeflowuniverse.crystallib.baobab.smartid

fn table_delete(mut db DB, args DBDeleteArgs) ! {
	name := table_name(db, args.objtype)
	mut statement := table_delete_statement(name, args)
	db.sqlitedb.exec(statement)!

	statement = table_delete_statement('data', args)
	db.sqlitedb.exec(statement)!
}

fn table_delete_statement(name string, args DBDeleteArgs) string {
	gid:=args.gid or {smartid.GID{}}
	oid:=gid.oid()
	q:=if oid> 0 {
		'DELETE from ${name} WHERE cid = ${args.cid.u32()} AND oid = ${oid}'
	}else{
		'DELETE from ${name} WHERE cid = ${args.cid.u32()}'
	}
	return q	
}

