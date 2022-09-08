module books
import os
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.gittools

// creates mdbook folder in tmp and 
// populates it with template and content file links
fn (site Site) mdbook_create() ? {
	
	// fetch template & content repositories
	mut gt := gittools.get(root: '')?
	mut books_repo := gt.repo_get_from_url(url: 'https://github.com/threefoldfoundation/books/tree/main/template/books/template')?
	mut dest_repo := gt.repo_get_from_path(site.path, true, false)?
	books_repo.pull()?

	//? ok to use os module or should use executor?
	tmp := "/tmp/mdbooks/"
	if !os.exists(tmp) {
		os.mkdir(tmp) ?
	}

	os.chdir("/tmp/mdbooks/") ?
	if !os.exists(site.name) {
		os.mkdir(site.name) ?
	}

	// links template into book dir
	os.chdir("/tmp/mdbooks/$site.name") ?	
	template_path := books_repo.path + '/template/books/template'
	os.execute('ln -s -f $template_path/theme .')
	os.execute('ln -sf $template_path/book.toml .')
	os.execute('ln -sf $template_path/*.sh .')
	os.execute('ln -sf $template_path/mermaid* .')

	if !os.exists('src') {
		os.mkdir('src') ?
	}
	os.execute('ln -s $site.path.path/* src')
}

fn (site Site) mdbook_update() ? {

	if !os.exists('/tmp/mdbooks/$site.name') {
		site.mdbook_create()?
	}

	mut gt := gittools.get(root: '')?
	mut books_repo := gt.repo_get_from_url(url: 'https://github.com/threefoldfoundation/books/tree/main/template/books/template')?
	books_repo.pull()?

}


//open the development tool and the browser to show the book you are working on
pub fn (site Site) mdbook_develop() ? {	
	
	mdbook.install()?
	site.mdbook_update()?

	mut gt := gittools.get(root: '')?
	mut dest_repo := gt.repo_get_from_path(site.path, true, false)?

	os.chdir("/tmp/mdbooks/$site.name") ?	
	os.execute('sh develop.sh')
}



//export an mdbook to its html representation
pub fn (site Site) mdbook_export() ? {	
	println('running running')
	mdbook.install()?
	site.mdbook_update()?
	os.chdir("/tmp/mdbooks/$site.name") ?	
	os.execute('mdbook build')
}
