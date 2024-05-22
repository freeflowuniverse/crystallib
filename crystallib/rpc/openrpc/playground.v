module openrpc

import json
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.webtools.npm
import vweb
import os

pub struct Playground {
	vweb.Context
	dest pathlib.Path @[vweb_global]
}

@[params]
pub struct PlaygroundConfig {
pub:
	dest pathlib.Path @[required]
	specs []pathlib.Path
}

pub fn export_playground(config PlaygroundConfig) ! {
	// tw := tailwind.new(
	// 	name: 'publisher'
	// 	path_build: '${os.dir(@FILE)}'
	// 	content_paths: [
	// 		'${os.dir(@FILE)}/templates/**/*.html',
	// 	]
	// )!
	// css_source := '${os.dir(@FILE)}/templates/css/index.css'
	// css_dest := '${os.dir(@FILE)}/static/css/index.css'
	// tw.compile(css_source, css_dest)!
	println('getting git')
	mut gs := gittools.new() or {panic(err)}
	println('getting locator')
	mut locator := gs.locator_new('https://github.com/open-rpc/playground') or {panic(err)}
	println('getting repo')
	repo := gs.repo_get(locator: locator, reset: false) or {panic(err)}
	
	playground_dir := repo.path

	mut project := npm.new_project(playground_dir.path)!
	println('installing')
	project.install()
	println('exporting examples')
	export_examples(config.specs, '${playground_dir.path}/src')!
	println('building')
	project.build()!
	println('exporting')
	project.export(config.dest)!
}

pub fn new_playground(config PlaygroundConfig) !&Playground {
	mut pg := Playground{dest: config.dest}
	pg.serve_examples(config.specs)!
	pg.mount_static_folder_at('${config.dest.path}/static', '/static')
	return &pg
}

struct ExampleSpec {
	name string
	url string
}

fn export_examples(specs_ []pathlib.Path, src_path string) ! {
	mut specs := specs_.clone()
	mut examples_file := pathlib.get_file(
		path:'${src_path}/examplesList.tsx'
	)!

	mut examples := []ExampleSpec{}

	for mut spec in specs {
		o := openrpc.decode(spec.read()!)!
		name := texttools.name_fix(o.info.title)
		examples << ExampleSpec{
			name: name
			url: '/specs/${name}.json'
		}
	}
	mut examples_str := "export default ${json.encode(examples)}"
	examples_file.write(examples_str)!
}

fn (mut pg Playground) serve_examples(specs_ []pathlib.Path) ! {
	mut specs := specs_.clone()
	for mut spec in specs {
		o := openrpc.decode(spec.read()!)!
		name := texttools.name_fix(o.info.title)
		pg.serve_static('/specs/${name}.json', spec.path)
	}
}

pub fn (mut pg Playground) index() vweb.Result {
	mut index := pathlib.get_file(path: '${pg.dest.path}/index.html') or {
		panic(err)
	}
	return pg.html(index.read() or {panic(err)})
}