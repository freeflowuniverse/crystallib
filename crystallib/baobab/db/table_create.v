module db

fn table_create(mut db DB, mut args DBTableCreateArgs) ! {
	tablename, tablecmd, indexsql := table_create_statements(mut db, mut args)!
	db.sqlitedb.exec(tablecmd)!
	if !(index_exists(mut db, tablename)) {
		db.sqlitedb.exec(indexsql)!
	}
}

fn tables_create_core(mut db DB) ! {
	mut datatable := 'CREATE TABLE IF NOT EXISTS data (\n'
	datatable += 'data BLOB,\n'
	datatable += 'cid INTEGER,\n'
	datatable += 'oid INTEGER\n'
	datatable += '\n);\n'

	db.sqlitedb.exec(datatable)!

	if !(index_exists(mut db, 'data')) {
		indextable := 'CREATE INDEX data_index ON data (cid,oid);'
		db.sqlitedb.exec(indextable)!
	}

	// println(datatable)
}

fn index_exists(mut db DB, name string) bool {
	r := db.sqlitedb.exec("
    	SELECT 1 FROM sqlite_master
    	WHERE type='index' AND name='${name}_index' AND tbl_name='${name}'
		") or {
		return false
	}
	if r.len > 0 {
		return true
	}
	return false
}

fn table_create_statements(mut db DB, mut args DBTableCreateArgs) !(string, string, string) {
	if args.objtype.len == 0 {
		return error('objtype needs to be specified')
	}
	tablename := table_name(db, args.objtype)
	mut searchtable := 'CREATE TABLE IF NOT EXISTS ${tablename} (\n'
	mut toindex := ['cid', 'oid', 'mtime']
	searchtable += 'cid INTEGER,\n'
	searchtable += 'oid INTEGER,\n'
	searchtable += 'mtime INTEGER,\n'
	for key in args.index_int {
		searchtable += '${key} INTEGER,\n'
		toindex << key
	}
	for key in args.index_string {
		searchtable += '${key} STRING,\n'
		toindex << key
	}
	searchtable = searchtable.trim_right(' \n,')
	searchtable += '\n);\n'

	toindexstr := toindex.join(',').trim_right(',')

	indextable := 'CREATE INDEX ${tablename}_index ON ${tablename} (${toindexstr});'

	// println(searchtable)
	// println(indextable)

	return tablename, searchtable, indextable
}
