module books

import freeflowuniverse.crystallib.pathlib


fn (site Site) template_write(path string, content string)?{
	mut dest_path := pathlib.get('${site.path.path}/books/$site.name/$path')
	dest_path.write(content)?
}

fn (site Site) template_install()?{

	if site.title == ""{
		site.title = site.name
	}

	site.template_write("theme/css/print.css",$tmpl("template/theme/css/print.css"))?
	site.template_write("theme/css/variables.css",$tmpl("template/theme/css/variables.css"))?
	site.template_write("book.toml",$tmpl("template/book.toml"))?
	site.template_write("mermaid-init.js",$tmpl("template/mermaid-init.js"))?
	site.template_write("mermaid.min.js",$tmpl("template/mermaid.min.js"))?


}