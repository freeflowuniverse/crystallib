module db

import strings
import encoding.base32

fn table_find(mut db DB, args DBFindArgs) ![][]u8 {
	sql_statement := table_find_statement(mut db, args)
	mut oids := []int{}
	mut cids := []int{}

	rows := db.sqlitedb.exec(sql_statement)!
	if rows.len == 0 {
		return [][]u8{}
	}

	for _, row in rows {
		if row.vals.len != 2 {
			panic('inalid record, row must consist of cid and oid only, ${row} is returned')
		}
		cids << row.vals[0].int()
		oids << row.vals[1].int()
	}

	data_sql := multiple_data_query(cids, oids)
	data_rows := db.sqlitedb.exec(data_sql)!

	mut data := [][]u8{}
	for _, data_row in data_rows {
		data_str := base32.decode_string_to_string(data_row.vals[0])!
		data << data_str.bytes()
	}
	return data
}

fn table_find_statement(mut db DB, args DBFindArgs) string {
	tn := table_name(db, args.objtype)
	mut b := strings.new_builder(15)
	b.write_string('SELECT cid, oid FROM ${tn}')
	if args.query_int.len == 0 && args.query_string.len == 0 {
		b.write_byte(`;`)
		return b.str()
	}

	and_str := 'AND '
	b.write_string(' WHERE ')

	for k, v in args.query_int_less {
		b.write_string('${k} < ${v} ${and_str}')
	}

	for k, v in args.query_int_greater {
		b.write_string('${k} > ${v} ${and_str}')
	}

	for k, v in args.query_int {
		b.write_string('${k} = ${v} ${and_str}')
	}

	for k, v in args.query_string {
		b.write_string('${k} = \'${v}\' ${and_str}')
	}

	b.cut_last(and_str.len)

	b.write_byte(`;`)

	return b.str()
}

fn multiple_data_query(cids []int, oids []int) string {
	mut b := strings.new_builder(20)
	b.write_string('SELECT data FROM data WHERE oid IN (')
	for id, _ in cids {
		b.write_string('${oids[id]}, ')
	}

	b.cut_last(2)
	b.write_string(' );')
	return b.str()
}
