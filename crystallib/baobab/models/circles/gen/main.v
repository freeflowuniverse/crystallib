module main

import os

const (
	source_model   = '${os.dir(os.dir(@FILE))}/model.v'
	actor_target   = '${os.dir(os.dir(@FILE))}/actor2.v'
	methods_target = '${os.dir(os.dir(@FILE))}/methods2.v'
)

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	// methods := generate_methods(model_path: source_model)!
	// os.write_file(methods_target, methods)!
	// os.execute('v fmt -w ${methods_target}')

	// actor := generate_actor(model_path: methods_target)!
	// os.write_file(actor_target, actor)!
	// os.execute('v fmt -w ${actor_target}')
}
