module data
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.params


fn (mut generator CodeGenerator) generate() ! {

	for domain in generator.domains{
		mut domain_path:=generator.path_out.dir_get_new(domain.name_lower)! //make sure path for 
		for actor in domain.actors{
			mut actor_path:=domain_path.dir_get_new(actor.name_lower)!
			for model in actor.models{
				mut model_path:=domain_path.file_get_new(model.name_lower)!
			}
		}
	}



}