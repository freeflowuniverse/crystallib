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
	build pathlib.Path @[vweb_global]
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
	mut gs := gittools.new() or {panic(err)}
	mut locator := gs.locator_new('https://github.com/freeflowuniverse/playground') or {panic(err)}
	repo := gs.repo_get(locator: locator, reset: false) or {panic(err)}
	
	playground_dir := repo.path

	mut project := npm.new_project(playground_dir.path)!
	project.install()
	// export_examples(config.specs, '${playground_dir.path}/src')!
	project.build()!
	project.export(config.dest)!
}

const build_path = '${os.dir(@FILE)}/playground'


pub fn new_playground(config PlaygroundConfig) !&Playground {
	build_dir := pathlib.get_dir(path: build_path)!
	mut pg := Playground{build: build_dir}
	pg.serve_examples(config.specs)!
	pg.mount_static_folder_at('${build_dir.path}/static', '/static')
	
	mut env_file := pathlib.get_file(path: '${build_dir.path}/env.js')!
	env_file.write(encode_env(config.specs)!)!
	pg.serve_static('/env.js', env_file.path)
	return &pg
}

struct ExampleSpec {
	name string
	url string
}

fn encode_env(specs_ []pathlib.Path) !string {
	mut specs := specs_.clone()
	mut examples := []ExampleSpec{}

	for mut spec in specs {
		o := openrpc.decode(spec.read()!)!
		name := texttools.name_fix(o.info.title)
		examples << ExampleSpec{
			name: name
			url: '/specs/${name}.json'
		}
	}
	mut examples_str := "window._env_ = { ACTORS: '${json.encode(examples)}' }"
	return examples_str
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
	mut index := pathlib.get_file(path: '${pg.build.path}/index.html') or {
		panic(err)
	}
	return pg.html(index.read() or {panic(err)})
}