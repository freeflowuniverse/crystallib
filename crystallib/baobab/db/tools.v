module db

fn table_name(db DB, objtype string) string {
	tablename := '${db.cid.str()}_${objtype}'
	return tablename
}
