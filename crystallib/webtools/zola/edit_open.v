module zola

import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.develop.vscode
import freeflowuniverse.crystallib.osal
import os

pub fn site_open(name string) ! {
	mut r := redisclient.core_get()!
	mut path_publish := r.get('zola:${name}:publish')!
	path_publish = path_publish.replace('~', os.home_dir())
	if path_publish.len == 0 {
		return error("can't find site: ${name}, was it generated before?")
	}
	if !os.exists(path_publish) {
		return error("can't find generated site in ${path_publish}, was it generated properly.")
	}
	cmd3 := "open '${path_publish}/index.html'"
	println(cmd3)
	osal.exec(cmd: cmd3)!
}

// pub fn site_edit(name string) ! {
// 	mut r := redisclient.core_get()!
// 	path_build := r.get('zola:${name}:build')!
// 	if path_build.len == 0 {
// 		return error("can't find site: ${name}, was it generated before?")
// 	}
// 	edit_path := '${path_build}/edit'.replace('~', os.home_dir())
// 	if !os.exists(edit_path) {
// 		return error("can't find site edit path in ${edit_path}, was it generated properly.")
// 	}
// 	println('open: ${edit_path}')
// 	vscode.open(path: edit_path)!
// }
