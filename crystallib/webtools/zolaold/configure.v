module zola

// import freeflowuniverse.crystallib.core.play

// @[heap]
// pub struct WebSiteConfig {
// pub mut:
// 	instance     string
// 	name         string
// 	coderoot     string
// 	path_build   string
// 	path_publish string
// 	collections  []WebSiteCollectionConfig
// }

// @[heap]
// pub struct WebSiteCollectionConfig {
// pub mut:
// 	name       string
// 	url        string
// 	cat        ContentCat
// 	prefix_dir string // subdir inside the destination for the content category
// }

// pub enum ContentCat {
// 	content
// 	css
// 	template
// 	static_css
// 	static_images
// }

// // get the configurator
// pub fn configurator(name string, mut context play.Context) !play.Configurator[WebSiteConfig] {
// 	mut c := play.configurator_new[WebSiteConfig](
// 		name: 'website'
// 		instance: name
// 		context: context
// 	)!
// 	return c
// }

// @[params]
// pub struct NewFromConfigArgs {
// pub mut:
// 	websites ?&Zola
// 	instance string        @[required]
// 	reset    bool
// 	context  &play.Context @[required]
// }

// // load the object from a configuration instance, which comes from context
// pub fn new_from_config(args_ NewFromConfigArgs) !&ZolaSite {
// 	mut args := args_

// 	mut c := configurator(args.instance, mut args.context)!

// 	myconfig := c.get()!

// 	mut websites := args.websites or {
// 		mut websites_ := new(
// 			coderoot: myconfig.coderoot
// 			buildroot: myconfig.path_build
// 			publishroot: myconfig.path_publish
// 			install: true
// 		)!
// 		&websites_
// 	}

// 	mut website := websites.site_new(
// 		name: myconfig.name
// 		// url: myconfig.url
// 	)!

// 	for collection in myconfig.collections {
// 		website.collection_add(name: collection.name, url: collection.url)!
// 	}

// 	// websites.init()!

// 	return website
// }

// // save the object to a config on the filesystem as part of the context
// pub fn save_to_config(website ZolaSite, mut context play.Context) ! {
// 	if website.name == '' {
// 		return error('need name for website, now empty.')
// 	}
// 	mut c := configurator(website.name, mut context)!
// 	// mut myconfig := WebSiteConfig{
// 	// 	name: website.name
// 	// 	coderoot: website.zola.coderoot
// 	// 	path_build: website.zola.path_build
// 	// 	path_publish: website.zola.path_publish

// 	// }

// 	// instance     string
// 	// name         string
// 	// coderoot     string
// 	// path_build   string
// 	// path_publish string

// 	// for collection in website.collections {
// 	// 	myconfig.collections << WebSiteCollectionConfig{
// 	// 		name: collection.name
// 	// 		url: collection.url
// 	// 	}
// 	// }

// 	// c.set(myconfig)!
// }
