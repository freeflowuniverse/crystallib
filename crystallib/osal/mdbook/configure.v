module mdbook

import freeflowuniverse.crystallib.core.play

@[heap]
pub struct MDBookConfig {
pub mut:
	instance     string
	name         string
	url          string
	coderoot     string
	path_build   string
	path_publish string
	collections  []MDBookCollectionConfig
	// gitrepokey   string
	title string
}

@[heap]
pub struct MDBookCollectionConfig {
pub mut:
	name string
	url  string
	// gitrepokey string
	path       string
}

// get the configurator
pub fn configurator(name string, mut context play.Context) !play.Configurator[MDBookConfig] {
	mut c := play.configurator_new[MDBookConfig](
		name: 'mdbook'
		instance: name
		context: context
	)!
	return c
}

@[params]
pub struct NewFromConfigArgs {
pub mut:
	books    ?&MDBooks
	instance string        @[required]
	reset    bool
	context  &play.Context @[required]
}

// load the object from a configuration instance, which comes from context
pub fn new_from_config(args_ NewFromConfigArgs) !&MDBook {
	mut args := args_

	mut c := configurator(args.instance, mut args.context)!

	myconfig := c.get()!

	mut books := args.books or {
		mut books_ := new(
			coderoot: myconfig.coderoot
			buildroot: myconfig.path_build
			publishroot: myconfig.path_publish
			install: true
		)!
		&books_
	}

	mut book := books.book_new(
		name: myconfig.name
		url: myconfig.url
		title: myconfig.title
	)!

	for collection in myconfig.collections {
		book.collection_add(name: collection.name, url: collection.url,path:collection.path)!
	}

	books.init()!

	return book
}

// save the object to a config on the filesystem as part of the context
pub fn save_to_config(mdbook MDBook, mut context play.Context) ! {
	if mdbook.name == '' {
		return error('need name for mdbook, now empty.')
	}
	mut c := configurator(mdbook.name, mut context)!
	mut myconfig := MDBookConfig{
		name: mdbook.name
		url: mdbook.url
		coderoot: mdbook.books.coderoot
		path_build: mdbook.books.path_build
		path_publish: mdbook.books.path_publish
		title: mdbook.title
	}

	for collection in mdbook.collections {
		myconfig.collections << MDBookCollectionConfig{
			name: collection.name
			url: collection.url
			path: collection.path.path
		}
	}

	c.set(myconfig)!
}
