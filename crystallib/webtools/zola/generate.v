module zola

import freeflowuniverse.crystallib.webtools.tailwind
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.webcomponents.preprocessor
import freeflowuniverse.crystallib.core.texttools
import os

pub fn (mut site ZolaSite) generate() ! {
	console.print_header(' website generate: ${site.name} on ${site.path_build.path}')

	mut tw := tailwind.new(
		name: site.name
		path_build: site.path_build.path
		content_paths: ['${site.path_build.path}/templates/**/*.html',
			'${site.path_build.path}/content/**/*.md']
	)!

	css_source := '${site.path_build.path}/css/index.css'
	css_dest := '${site.path_build.path}/static/css/index.css'
	tw.compile(css_source, css_dest)!

	mut cmd := '        #!/usr/bin/env bash		
		set -e
		${osal.profile_path_source()}
		zola -r ${site.path_build.path} build -f -o ${site.path_publish.path}
		'
	cmd = texttools.dedent(cmd)
	mut p_build := pathlib.get_file(path: '${site.path_build.path}/build.sh', create: true)!
	p_build.write(cmd)!
	os.chmod(p_build.path, 0o777)!

	preprocessor.preprocess('${site.path_build.path}/content')!

	osal.exec(cmd: cmd)!
}

fn (mut site ZolaSite) template_install() ! {
	config := $tmpl('templates/config.toml')
	mut config_dest := pathlib.get('${site.path_build.path}/config.toml')
	config_dest.write(config)!
}
