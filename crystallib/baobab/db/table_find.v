module db

import strings
import encoding.base32

// [params]
// pub struct DBFindArgs {
// pub mut:
// 	cid               smartid.CID
// 	objtype           string
// 	query_int         map[string]int
// 	query_string      map[string]string
// 	query_int_less    map[string]int
// 	query_int_greater map[string]int
// }

// return list of data blocks which then need to be deserialized based on the DBFindArgs
fn table_find(mut db DB, args DBFindArgs) ![][]u8 {
	sql_statement_find := sql_build_find(mut db, args)
	mut oids := []int{}

	rows := db.sqlitedb.exec(sql_statement_find)!
	if rows.len == 0 {
		return [][]u8{}
	}

	for _, row in rows {
		if row.vals.len != 1 {
			panic('inalid record, row must consist of  oid only, ${row} is returned')
		}
		oids << row.vals[0].int()
	}

	sql_statement_multiget := sql_build_multiget(oids)
	data_rows := db.sqlitedb.exec(sql_statement_multiget)!

	mut data := [][]u8{}
	for _, data_row in data_rows {
		data_str := base32.decode_string_to_string(data_row.vals[0])!
		data << data_str.bytes()
	}
	return data
}

// build sql statement based on DBFindArgs
fn sql_build_find(mut db DB, args DBFindArgs) string {
	tn := table_name(db, args.objtype)
	mut b := strings.new_builder(15)
	b.write_string('SELECT oid FROM ${tn}')
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

fn sql_build_multiget(oids []int) string {
	mut b := strings.new_builder(20)
	b.write_string('SELECT data FROM data WHERE oid IN (')
	for id in oids {
		b.write_string('${id}, ')
	}
	b.cut_last(2)
	b.write_string(' );')
	return b.str()
}
