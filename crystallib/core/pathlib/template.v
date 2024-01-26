module pathlib

import freeflowuniverse.crystallib.core.texttools
import os
import freeflowuniverse.crystallib.ui.console

// template is the text coming from template engine.
pub fn template_write(template_ string, dest string, overwrite bool) ! {
	mut template := texttools.template_replace(template_)
	if overwrite || !(os.exists(dest)) {
		mut p := get_file(path: dest, create: true)!
		$if debug {
			console.print_header(" write template to '${dest}'")
		}
		p.write(template)!
	}
}

pub fn (mut path Path) template_write(template_ string, overwrite bool) ! {
	template_write(template_, path.path, overwrite)!
}
