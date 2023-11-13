module zola

// import freeflowuniverse.crystallib.osal
// import os
// import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct ZBook {
pub mut:
	books &ZBooks [skip; str: skip]
	name string
	path_src pathlib.Path
	path_export pathlib.Path
	collections []ZBookCollection
	gitrepokey string	
}


[params]
pub struct ZBookArgs {
pub mut:
	name string [required]
	url string [required] //url of the summary.md file
}


pub fn (mut books ZBooks) book_new(args ZBookArgs)!&ZBook{

	path_src:="/tmp/zolas_builder/${args.name}" //where builds happen
	path_export:="${books.path.path}/${args.name}"

	mut book:=ZBook{
		name:args.name
		path_src:pathlib.get_dir(path:path_src,create:true)!
		path_export:pathlib.get_dir(path:path_export,create:true)!
		books:&books
	}

	books.books<<&book

	return &book
}


pub fn (mut b ZBook) collection_add(args_ ZBookCollectionArgs)!{
	mut args:=args_
	mut c:=ZBookCollection{url:args.url,name:args.name,book:&b}
	c.get()!
	b.collections << c
}


pub fn (mut b ZBook) generate()!{
	println (" - book generate: ${b.name} on ${b.path_src}")
}

