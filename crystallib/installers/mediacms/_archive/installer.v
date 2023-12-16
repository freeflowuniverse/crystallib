module mediacms

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import os

struct TemplateItem {
	source string
	dest   string
}

pub fn install(args Config) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if osal.done_exists('mediacms_install') {
		println(' - mediacms already installed')
		return
	}

	mut gs := gittools.get()!

	mut path := gittools.code_get(
		url: 'https://github.com/mediacms-io/mediacms'
		pull: true
		reset: true
	)!

	mut ti := []TemplateItem{}
	dest := 'frontend/src/templates/config/installation'
	ti << TemplateItem{
		source: 'contents.config.js'
		dest: dest
	}
	ti << TemplateItem{
		source: 'features.config.js'
		dest: dest
	}
	ti << TemplateItem{
		source: 'site.config.js'
		dest: dest
	}
	ti << TemplateItem{
		source: 'pages.config.js'
		dest: dest
	}
	ti << TemplateItem{
		source: 'Dockerfile.py'
		dest: ''
	}
	ti << TemplateItem{
		source: 'docker-compose.yaml'
		dest: ''
	}
	ti << TemplateItem{
		source: 'settings.py'
		dest: 'cms'
	}

	// for i in ti{
	// 	mut c:=$tmpl("templates/${ti.name}")
	// 	c=c.replace("\@\@","\$")
	// 	dest_dir:="${path}/${i.dest}".trim_right("/")
	// 	if !(os.exists(dest_dir)){
	// 		return error("can't find dest in repo: $t")
	// 	}
	// 	mut p2:=pathlib.get_file(path:"${dest_dir}/${i.source}",create:true)!
	// 	println(" - write to source: ${p2.path}")
	// 	p2.write(c)!
	// }

	// build()!

	// osal.done_set('mediacms_install', 'OK')!

	println(' - mediacms installed properly.')
}
