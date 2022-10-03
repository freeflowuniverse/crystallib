module books

import freeflowuniverse.crystallib.installers.mdbook
// import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib

// const template_url='https://github.com/threefoldfoundation/books/tree/main/template/books/template'
// const gittools_root = ""

pub fn new() Sites {
	mut sites := Sites{}
	sites.config = Config{}
	return sites
}

// make sure all initialization has been done e.g. installing mdbook
pub fn (mut sites Sites) init() ? {
	if sites.state == .init {
		mdbook.install()?
		sites.embedded_files << $embed_file('template/theme/css/print.css')
		sites.embedded_files << $embed_file('template/theme/css/variables.css')
		sites.embedded_files << $embed_file('template/mermaid-init.js')
		sites.embedded_files << $embed_file('template/mermaid.min.js')

		sites.state = .initdone
	}
}

// reset all, just to make sure we regenerate fresh
pub fn (mut sites Sites) reset() ? {
	// delete where the books are created
	for item in ['books', 'html'] {
		mut a := pathlib.get(sites.config.dest + '/$item')
		a.delete()?
	}
	sites.state = .init // makes sure we re-init
	sites.init()?
}

// //will get the template info from our github for mdbooks
// pub fn (mut sites Sites) template_update() ? {
// 		mut gt := gittools.get(root:gittools_root)?
// 		mut books_repo := gt.repo_get_from_url(url: template_url)?
// 		books_repo.pull()?
// 		sites.reset()?
// }
