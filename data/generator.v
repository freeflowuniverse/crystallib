module data

// import freeflowuniverse.crystallib.texttools
// import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.params

fn (mut generator CodeGenerator) generate() ! {
	for mut domain in generator.domains {
		mut domain_path := generator.path_out.dir_get_new(domain.name)! // make sure path for
		for mut actor in domain.actors {
			mut actor_path := domain_path.dir_get_new(actor.name)!
			for mut model in actor.models {
<<<<<<< HEAD
				mut model_path := actor_path.file_get_new(model.name_lower + '.v')!
				content := $tmpl('templates/data_obj.v')
=======
				mut model_path := actor_path.file_get_new(model.name_lower + '.vtemplate')!
				content := $tmpl('templates/data_obj.vtemplate')
>>>>>>> 667df183094470ef5dbeba569d84a1ac2b27784e
				model_path.write(content)!
			}
		}
	}
}
