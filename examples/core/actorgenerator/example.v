module main

import freeflowuniverse.crystallib.core.actorgenerator
import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import os

const (
	model_path       = '${os.dir(@FILE)}/organization_model'
	destination_path = '${os.dir(@FILE)}/organization_actor/actor.v'
)

fn main() {
	generate_actor() or { panic(err) }
}

fn generate_actor() ! {
	code := codeparser.parse_v(model_path)!
	generator := actorgenerator.ActorGenerator{'example'}
	actor_code := generator.generate(code)!
	code_file := codemodel.new_file(
		mod: 'example'
		items: actor_code
	)
	code_file.write(destination: destination_path)!
}
