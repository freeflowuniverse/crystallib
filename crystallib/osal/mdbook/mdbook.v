module mdbook

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct MDBook {
pub mut:
	name string
	path_src pathlib.Path
	path_export pathlib.Path
	collections []MDBookCollection
	gitrepos map[string]gittools.GitRepo
	gitrepokey string
}


[params]
pub struct MDBookArgs {
pub mut:
	name string [required]
	path string [required]
	url string [required] //url of the summary.md file
}


pub fn new(args MDBookArgs)!MDBook{
	mdbook.install()!
	mut book=MDBook{
		name:args.name
		path:pathlib.get_dir(path:args.path,create:true)!
	}
	return book
}


pub fn (b MDBook) collection_add(args_ MDBookCollectionArgs)!{
	mut args:=args_
	mut c:=MDBookCollection{url:args.url,name:args.name,book:&b}
	c.pull()!
	b.collections << c
}


pub fn (b MDBook) check()!{
	mut changed:=false
	for key,repo in b.gitrepos{
		if repo.need_pull()!{
			repo.pull_reset()!
			changed=true
		}
	}
	if changed{
		b.generate()!
	}
}


pub fn (self MDBookCollection) pull()!{

	println(" - mdbook collection get: $self.url")

	mut gs := gittools.get()!
	locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator)!
	b.book.gitrepos[repo.key()] = repo
	args.path = repo.path.path

	path:=gittools.code_get(pull:self.pull,reset:self.reset,url:self.url)!
	println(" - mdbook collection: $path")


}
