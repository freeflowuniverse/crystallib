module meet

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

const templates = {
	'404.html': 'https://freeflowuniverse.github.io/livekit_meet/404.html',
	'custom.html': 'https://freeflowuniverse.github.io/livekit_meet/custom.html'
	'index.html': 'https://freeflowuniverse.github.io/livekit_meet/index.html'
	'room.html': 'https://freeflowuniverse.github.io/livekit_meet/rooms/room.html'
}

pub fn update_templates() !{

	pathlib.get_dir(path:'${os.dir(@FILE)}/templates' empty: true)!
	
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
		fixed = fixed.replace('@', '@@') // escape templating syntax
		fixed = fixed.replace('#{app.static_url}', '@{app.static_url}')
		fixed = fixed.replace('$', '@{dollar}')
		path.write(fixed)!
	}
}

pub struct BuildConfig {
	repo_url string // url of meet repository being built
	static_url string // url of where the static files are being served from
	base_url string // base url of the app
}

// pub fn build()