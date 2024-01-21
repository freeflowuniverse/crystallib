module bizmodel

import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.pathlib

pub fn (mut m BizModel) process_macros() ! {
	
	mut mdbook_source_path := pathlib.get_dir(path: m.params.mdbook_source, create: false)!

	mut pl:=mdbook_source_path.list()!


	for path in pl.paths{
		println(path)
		mut doc:=markdownparser.new(path:path.path)!

		if true{
			
			c:=doc.markdown()
			println("\n\n\n")
			println(c)

			panic("S")
		}


	}


}