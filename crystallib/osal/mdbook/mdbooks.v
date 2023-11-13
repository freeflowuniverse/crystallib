module mdbook

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct MDBooks {
pub mut:
	books []MDBook
	path_src pathlib.Path

}

[params]
pub struct MDBooksArgs {
pub mut:
	path string [required]
}


pub fn new(args MDBooksArgs)MDBooks{
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
