module zola
import freeflowuniverse.crystallib.webtools.tailwind
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

pub fn (mut site ZolaSite) generate() ! {
	console.print_header(' website generate: ${site.name} on ${site.path_build.path}')


	mut tw:=tailwind.new(
		name: site.name
		path_build: site.path_build.path
		content_paths: ['${site.path_build.path}/templates/**/*.html',
			'${site.path_build.path}/content/**/*.md']
	)!

	css_source := '${site.path_build.path}/css/index.css'
	css_dest := '${site.path_build.path}/static/css/index.css'
	tw.compile(css_source, css_dest)!

	osal.exec(
		cmd: '
		${osal.profile_path_source_and()}
		zola -r ${site.path_build.path} build -f -o ${site.path_publish.path}
		'
	)!
	if true{
		panic("555")
	}	

	// execute('rsync -a ${dir(@FILE)}/tmp_content/ ${dir(@FILE)}/content/')
	// rmdir_all('${dir(@FILE)}/tmp_content')!
	// os.mv('${site.path_build.path}/public', site.path_publish.path)!
}


fn (mut site ZolaSite) template_install() ! {
	
	config := $tmpl('templates/config.toml')
	mut config_dest := pathlib.get('${site.path_build.path}/config.toml')
	config_dest.write(config)!



}
