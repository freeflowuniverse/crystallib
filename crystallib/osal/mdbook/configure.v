module mdbook

import freeflowuniverse.crystallib.core.play

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

pub struct MDBookCollectionConfig {
pub mut:
	name string
	url  string
	// gitrepokey string
	// path       pathlib.Path //TODO: need to do path
}

// get the configurator
pub fn configurator(instance string, mut context play.Context) !play.Configurator[MDBookConfig] {
	mut c := play.configurator_new[MDBookConfig](
		name: 'mdbook'
		instance: instance
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

	println(myconfig)
	if true {
		panic('new_from_config')
	}

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
		book.collection_add(name: collection.name, url: collection.url)!
	}

	books.init()!

	return book
}

// save the object to a config on the filesystem as part of the context
pub fn save_to_config(mut mdbook MDBook, mut context play.Context) ! {
	mut c := configurator(mdbook.instance, mut context)!

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
		}
	}

	c.set(myconfig)!
}
