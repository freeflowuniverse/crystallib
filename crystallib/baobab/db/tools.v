module db

fn table_name_find(db DB) string {
	tablename := '${db.objtype}_find'
	return tablename
}

fn table_name_data(db DB) string {
	tablename := '${db.objtype}_data'
	return tablename
}
