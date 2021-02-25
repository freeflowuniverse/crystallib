import os
import publishermod

fn test_get_content_basic() {
	mut p := @FILE.split('/')
	p.pop()

	mut path := os.join_path(p.join('/'), '..', '..', 'examples')

	mut f := publishermod.new(path) or { panic(err) }
	f.check()
	mut wiki := f.site_get('wiki') or { panic('cant find wiki') }
	assert wiki.page_exists('roadmap')
	_ := wiki.page_get('roadmap', mut &f) or { panic('cant find page') }

	mut test := f.site_get('test') or { panic('cant find test') }
	page1 := f.page_get('docker_Compatibility.md') or { panic('cannot find doc 1 $err') }
	site1 := page1.site_get(mut &f) or { panic(err) }

	page2 := f.page_get('docker_Compatibility') or { panic('cannot find doc 2 $err') }
	site2 := page2.site_get(mut &f) or { panic(err) }

	// println(page2)
	page3 := f.page_get('test:docker_Compatibility') or { panic('cannot find doc 3 $err') }
	site3 := page3.site_get(mut &f) or { panic(err) }

	assert site1.name == site2.name
	assert site3.name == site2.name
	assert page3.name == page2.name
	assert page1.name == page2.name

	_ := f.page_get('test:docker_Compatibility') or { panic(err) }

	assert f.sites.len == 2
	assert f.sites[1].name == 'test'
	assert f.sites[0].name == 'wiki'
}

fn test_get_content1() {
	mut p := @FILE.split('/')
	p.pop()

	mut path := os.join_path(p.join('/'), '..', '..', 'examples')
	mut f := publishermod.new(path) or { panic(err) }
	f.check()
	fileobj := f.file_get('test:blockchain_dilema.png') or { panic(err) }
	// this has enough info to serve the file back
	println(fileobj.path_get(mut &f))
	println(fileobj)
	pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the file back
	println(pageobj.path_get(mut &f))
	println(pageobj)
}

fn test_get_content2() {
	mut p := @FILE.split('/')
	p.pop()

	mut path := os.join_path(p.join('/'), '..', '..', 'examples')

	mut f := publishermod.new(path) or { panic(err) }
	f.check()
	println('start')
	for site in f.sites {
		println(site.name)
	}
	assert f.sites.len == 2

	mut pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the file back
	println(pageobj.path_get(mut &f))
	pageobj.process(mut &f) or { panic(err) }
	e := pageobj.content

	// check includes & links worked well
	assert e.contains('TFGrid release 2.1')
	assert e.contains('TFGrid release 2.2')
	// println(e)
	assert e.contains('![](file__wiki__roadmap.png)')
}
