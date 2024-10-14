module meet

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools

const templates = {
	'404.html': 'https://freeflowuniverse.github.io/livekit_meet/404.html',
	'custom.html': 'https://freeflowuniverse.github.io/livekit_meet/custom.html'
	'index.html': 'https://freeflowuniverse.github.io/livekit_meet/index.html'
	'room.html': 'https://freeflowuniverse.github.io/livekit_meet/rooms/room.html'
}

pub struct BuildConfig {
pub:
	repo_url string = "https://github.com/freeflowuniverse/livekit_meet" // url of the livekit meet app repository
	static_url string = "https://freeflowuniverse.github.io/livekit_meet" // url of where the static assets are served 
	base_path string // base path of app (ie: /meet if root is /meet)
	livekit_url string @[required]
	livekit_api_key string @[required]
	livekit_api_secret string @[required]
}

pub fn build(config BuildConfig) ! {
	path := gittools.code_get(
		url: config.repo_url
	)!
	
	dollar := '$'
	mut config_file := pathlib.get_file(path: '${path}/next.config.js')!
	config_file.write($tmpl('./templates/next.config.js'))!
	
	mut env_file := pathlib.get_file(path: '${path}/.env.local')!
	env_file.write($tmpl('./templates/.env.local'))!

	osal.exec(cmd: 'bash ${path}/build.sh')!
}

pub fn update_templates() !{
	pathlib.get_dir(path:'${os.dir(@FILE)}/templates')!
	
	for name, url in templates {
		mut path := osal.download(
			name: name
			reset: true
			minsize_kb: 1
			url: url
			dest: '${os.dir(@FILE)}/templates/${name}'
		)!

		content := path.read()!
		mut fixed := content.replace('@{app.static_url}', '#{app.static_url}')
		fixed = fixed.replace('@@', '@') // escape templating syntax
		fixed = fixed.replace('@', '@@') // escape templating syntax
		fixed = fixed.replace('#{app.static_url}', '@{app.static_url}')
		fixed = fixed.replace('$', '@{dollar}')
		path.write(fixed)!
	}
}