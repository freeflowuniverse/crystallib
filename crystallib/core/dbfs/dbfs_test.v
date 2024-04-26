module dbfs

fn test_dbfs() {
	mut dbcollection := get(context: 'test', secret: '123456')!

	mut db := dbcollection.get_encrypted('db_a')!

	db.set('a', 'bbbb')!
	assert 'bbbb' == db.get('a')!

	assert db.exists('a')

	db.delete('a')!
	assert db.exists('a') == false

	assert exists('test')

	db.set('a', 'bbbb')!

	dbcollection.destroy()!

	assert dbcollection.exists('a') == false

	assert exists('test') == false
}

fn test_dbfs2() {
	mut dbcollection := get(context: 'test', secret: '123456')!

	mut db := dbcollection.get('db_b')!

	db.set('a', 'bbbb')!
	assert 'bbbb' == db.get('a')!

	assert db.exists('a')
	assert !db.exists('ad')

	assert exists('test')

	dbcollection.destroy()!

	assert dbcollection.exists('a') == false

	assert exists('test') == false

	assert db.encrypted == false
}
