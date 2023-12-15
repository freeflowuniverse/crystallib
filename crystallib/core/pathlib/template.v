module pathlib

import os

// template is the text coming from template engine.
pub fn template_write(template_ string, dest string, overwrite bool) ! {
	mut template := template_replace(template_)
	if overwrite || !(os.exists(dest)) {
		mut p := get_file(path: dest, create: true)!
		$if debug {
			println(" - write template to '${dest}'")
		}
		p.write(template)!
	}
}

//replace '^^', '@' .
//replace '??', '$' .
//replace '\t', '    ' .
pub fn template_replace(template_ string, ) string {
	mut template := template_
	template = template.replace('^^', '@')
	template = template.replace('???', '$(')
	template = template.replace('??', '$')
	template = template.replace('\t', '    ')
	return template
}
