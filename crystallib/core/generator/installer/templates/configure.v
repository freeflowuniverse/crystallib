module ${args.name}

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal.gittools

pub fn configure(args Config) ! {

	checkplatform()!

	@for t in template_items
	mut ${t.name}:=$tmpl("templates/${t.path}")
	${t.name}=${t.name}.replace("@@@","@@")
	@if t.dest.len>0
	if !(os.exists("${t.dest}")){
		return error("can't find dest: ${t.dest}")
	}
	mut p2:=pathlib.get_file(path:"${t.dest}/${t.file_name()}",create:true)!
	println(" - write to source: ${p2.path}")
	p2.write(${t.name})!
	@end
	@end	

	@@if debug{println(' - ${args.name} configured properly.')}
}


fn checkplatform() ! {

	myplatform:=osal.platform()
	if !(${checkplatform}) {
		return error('platform not supported')
	}	

}
