module main
import os
import freeflowuniverse.crystallib.data
// import freeflowuniverse.crystallib.data.model

const model_in = os.dir(@FILE) + '/model_in'
const model_out = os.dir(@FILE) + '/model'

fn do() ! {

	mut generator:=data.generate(model_in,model_out)!
	os.write_file("$model_out/generator_dump.v",generator.str())!
	
	// mut df := model.factory()
	// df.init('/tmp/model_data', true)?

	// mut user := df.user_get(id: 1)?

	// mut user := model.user_new()?
	// user.name = "test"
	// user.remarks = [1,2]
	// println(user.changed())
	// user.remarks << 4
	// println(user.changed())
	// user.save()?
	// println(user)
}

fn main() {
	do() or { panic(err) }
}
