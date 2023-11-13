module mdbook

// import freeflowuniverse.crystallib.osal
// import os
// import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct MDBook {
pub mut:
	books &MDBooks [skip; str: skip]
	name string
	path_src pathlib.Path
	path_export pathlib.Path
	collections []MDBookCollection
	gitrepokey string	
}


[params]
pub struct MDBookArgs {
pub mut:
	name string [required]
	url string [required] //url of the summary.md file
}


pub fn (mut books MDBooks) book_new(args MDBookArgs)!&MDBook{

	path_src:="/tmp/mdbooks_builder/${args.name}" //where builds happen
	path_export:="${books.path.path}/${args.name}"

	mut book:=MDBook{
		name:args.name
		path_src:pathlib.get_dir(path:path_src,create:true)!
		path_export:pathlib.get_dir(path:path_export,create:true)!
		books:&books
	}

	books.books<<&book

	return &book
}


pub fn (mut b MDBook) collection_add(args_ MDBookCollectionArgs)!{
	mut args:=args_
	mut c:=MDBookCollection{url:args.url,name:args.name,book:&b}
	c.get()!
	b.collections << c
}


pub fn (mut b MDBook) generate()!{
	println (" - book generate: ${b.name} on ${b.path_src}")
}

