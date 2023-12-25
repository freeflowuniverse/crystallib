module pathlib
import freeflowuniverse.crystallib.core.texttools
import os

// template is the text coming from template engine.
pub fn template_write(template_ string, dest string, overwrite bool) ! {
	mut template := texttools.template_replace(template_)
	if overwrite || !(os.exists(dest)) {
		mut p := get_file(path: dest, create: true)!
		$if debug {
			println(" - write template to '${dest}'")
		}
		p.write(template)!
	}
}