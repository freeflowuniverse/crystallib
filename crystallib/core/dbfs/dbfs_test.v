module dbfs

import time

fn test_dbfs() {
	mut dbcollection := get(contextid: 0, secret: '123456')!

	mut db := dbcollection.db_create(name: 'db_a', encrypted: true, withkeys: true)!

	id := db.set(key: 'a', value: 'bbbb')!
	assert 'bbbb' == db.get(id: id, key: 'a')!

	assert db.exists(key: 'a')

	db.delete(key: 'a')!
	assert db.exists(key: 'a') == false

	assert db.exists(key: 'test') == false

	dbcollection.destroy()!

	assert dbcollection.exists('a') == false

	assert db.exists(key: 'test') == false
}

fn test_dbfs2() {
	mut dbcollection := get(contextid: 0, secret: '123456')!

	mut db := dbcollection.db_create(name:'hamada', withkeys: true)!

	id := db.set(key: 'a', value: 'bbbb')!
	assert 'bbbb' == db.get(id: id, key: 'a')!

	assert db.exists(key: 'a')
	assert !db.exists(key: 'ad')

	assert dbcollection.exists('hamada')

	dbcollection.destroy()!

	assert dbcollection.exists('a') == false

	assert db.exists(key: 'test') == false

	assert db.is_encrypted() == false
}
