module knowledgetree
import v.embed_file

//has the knowledge in how to deal with mdboos

[heap]
pub struct MDBooks {
pub mut:
	tree  	 &Tree            [str: skip]
	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a book
}

fn (mut tree Tree) mdbooks_init()!{
	mut b:=MDBooks{
		tree: &tree
	}
	mdbook.install()! //not sure where this is, needs to be in installers, using our osal
	b.embedded_files << $embed_file('template/theme/css/print.css')
	b.embedded_files << $embed_file('template/theme/css/variables.css')
	b.embedded_files << $embed_file('template/mermaid-init.js')
	b.embedded_files << $embed_file('template/mermaid.min.js') //TODO make sure all files are embedded
}


// reset all, just to make sure we regenerate fresh
pub fn (mut mdbooks MDBooks) reset() ! {
	for _, mut book in mdbooks.tree.books {
		book.reset()!
	}
}

// export the mdbooks to html
pub fn (mut mdbooks MDBooks) export() ! {
	mdbook.reset()! // make sure we start from scratch
	mdbook.fix()!
	for _, mut book in mdbooks.tree.books {
		book.export()! 
	}
}


