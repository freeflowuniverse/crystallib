module pathlib
import os

//template is the text coming from template engine.
pub fn  template_write(template_ string,dest string,overwrite bool)!{
	mut template:=template_
	template=template.replace("^^","@")
	template=template.replace("??","$")
	template=template.replace("\t","    ")	
	if overwrite || !(os.exists(dest)){
		mut p:=pathlib.get_file(path:dest,create:true)!
		$if debug{println(" - write template to '${dest}'")}
		p.write(template)!
	}
}
