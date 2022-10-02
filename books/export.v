module books

import os

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib

// open the development tool and the browser to show the book you are working on
// pub fn (site Site) mdbook_develop() ? {
// 	os.chdir('/tmp/mdbooks/$site.name')?
// 	os.execute('sh develop.sh')
// }

// export an mdbook to its html representation
pub fn (site Site) mdbook_export() ? {
	site.template_install()? //make sure all required template files are in site
	dest:=site.sites.config.dest
	book_path := '$dest/books/$site.name'
	html_path := '$dest/html/$site.name'

	//lets now walk over images & pages and we need to export it to there

	//lets now build
	os.execute('mdbook build $book_path --dest-dir $html_path')
}

//export the mdbooks to html
pub fn (mut sites Sites) mdbook_export() ? {
	sites.reset()? //make sure we start from scratch
	for _,site in sites.sites{
		site.mdbook_export()?
	}

}

