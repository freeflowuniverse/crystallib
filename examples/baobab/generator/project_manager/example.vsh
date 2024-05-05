#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.baobab.generator
import freeflowuniverse.crystallib.core.codemodel {Struct}
import freeflowuniverse.crystallib.core.codeparser
import os

const dest_dir = '${os.dir(@FILE)}/project_manager'

gen := generator.ActorGenerator{
	model_name: 'TestActor'
}

if os.exists(dest_dir) {
	os.rmdir_all(dest_dir)!
}

// lets generate an actor called ProjectManager
actor_code_file := gen.generate_actor()
actor_code_file.write_v(dest_dir)!

// lets parse the struct for which we will generate code
story_model := codeparser.parse_v('${os.dir(@FILE)}/source/story_model.v')!
story_struct := story_model[0] as Struct

object_code_file := gen.generate_object_code(root_struct: story_struct, actor_name: 'TestActor')
object_code_file.write_v('${os.dir(@FILE)}/project_manager', format: true)!

object_test_code_file := gen.generate_object_test_code(root_struct: story_struct, actor_name: 'TestActor')!
object_test_code_file.write_v('${os.dir(@FILE)}/project_manager', format: true)!

os.execute('v -cg -enable-globals -w test ${os.dir(@FILE)}/project_manager')