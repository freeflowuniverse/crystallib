module fskvs

fn test_fskvs() {

	contextdb_configure(name: 'test', secret: '123456')!

	mut contextdb := contextdb_get(name: 'test')!
	contextdb.db_configure(encrypted:true)!

	mut db := contextdb.db_get()! //will be the default one

	db.set('a', 'bbbb')!
	assert 'bbbb' == db.get('a')!

	contextdb.db_configure(encrypted:false)!
	mut db2 := contextdb.db_get()!
	assert 'bbbb' != db2.get('a')! // because then we are sure its encrypted

	contextdb.destroy()!

	assert contextdb.db_exists('default')==false

	assert contextdb_exists('test')==false
}

fn test_fskvs2() {
	contextdb_configure(name: 'test', secret: '1234567')!

	mut contextdb := contextdb_get(name: 'test')!
	contextdb.db_configure(encrypted:true)!

	mut db := contextdb.db_get()! //will be the default one

	for i in 0 .. 100 {
		db.set('${i}', '${i}')!
		assert '${i}' == db.get('${i}')!
	}

	contextdb.destroy()!
}
