module modelgenerator

// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.data.params

fn (mut generator CodeGenerator) generate() ! {
	for mut domain in generator.domains {
		mut domain_path := generator.path_out.dir_get_new(domain.name)! // make sure path for
		for mut actor in domain.actors {
			mut actor_path := domain_path.dir_get_new(actor.name)!
			for mut model in actor.models {
				mut model_path := actor_path.file_get_new(model.name_lower + '.vtemplate')!
				content := $tmpl('templates/data_obj.vtemplate')
				model_path.write(content)!
			}
		}
	}
}
