module main

struct DB{
pub mut:
	items []Item	
}

struct Item{
pub mut:
	nr int 
}


fn (mut db DB) get(nr) &Item {
	mut l:= &db.items[nr] or {panic("s")}
	return l
}	

fn do() ! {

	mut db:=DB{}

	for i in 0..10{
		db.items << Item{nr:i}
	}

	// println(db)

	db.items[5].nr=999

	// println(db)

	mut item:= &db.items[5]

	item.nr = 888

	println(db)	

	mut item2:=db.get(2)
	item2.nr=4444


	println(db)	

	//REMARK: shouldn't we be able to change nr to 4444? don't see in result

}

fn main() {
	do() or { panic(err) }
}
