module db

import freeflowuniverse.crystallib.baobab.smartid

fn table_read(mut db DB, g smartid.GID) ![]u8 {
	statement := 'SELECT data FROM data WHERE cid = ${g.cid.u32()} AND oid = ${g.oid()};'
	rows := db.sqlitedb.exec(statement)!

	if rows.len == 0 {
		return []u8{}
	}

	// gid identifies a record, so one record only should be returned
	if rows.len > 1 {
		return error('${rows.len} records matched the provided gid, while only one is expected')
	}

	mut row := rows[0]

	if row.vals.len == 0 {
		return error('row with gid ${g} is found, but data field is missing')
	}

	mut data_str := row.vals[0].trim('[]')
	mut data := []u8{}
	for _, s in data_str.split(', ') {
		data << s.u8()
	}

	return data
}
