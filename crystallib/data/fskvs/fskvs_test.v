module fskvs



fn test_fskvs() {

	mut db:=new(name:"test", secret:"1234")!

	db.set("a",'bbbb')!
	assert 'bbbb'==db.get("a")!


	mut db2:=new(name:"test")!
	assert 'bbbb'!=db2.get("a")! //because then we are sure its encrypted

	db2.set("a2",'bbbb2')!
	assert 'bbbb2'==db2.get("a2")!


}

