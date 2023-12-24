module fskvs

fn test_fskvs() {
	mut context := new(context: 'test', secret: '1234')!
	mut db := context.get(name: 'test1', encryption: true)!

	db.set('a', 'bbbb')!
	assert 'bbbb' == db.get('a')!

	mut db2 := context.get(name: 'test2', encryption: true)!
	assert 'bbbb' != db2.get('a')! // because then we are sure its encrypted

	db2.set('a2', 'bbbb2')!
	assert 'bbbb2' == db2.get('a2')!

	context.destroy()!
}

fn test_fskvs2() {
	mut context := new(context: 'test', secret: '1234')!
	mut db := context.get(name: 'test3', encryption: true)!

	for i in 0 .. 100 {
		db.set('${i}', '${i}')!
		assert '${i}' == db.get('${i}')!
	}

	context.destroy()!
}
