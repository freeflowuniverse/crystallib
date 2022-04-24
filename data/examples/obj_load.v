module main

import data.model




fn do()?{

	mut df := model.factory()	
	df.init("/tmp/model_data",true)?

	mut user := df.user_get(id:1)?

	// mut user := model.user_new()?
	// user.name = "test"
	// user.remarks = [1,2]
	// println(user.changed())
	// user.remarks << 4
	// println(user.changed())
	// user.save()?
	println(user)

}

fn main() {

	do() or {panic(err)}

}
