module books


fn (site Site) template_write(path string, content string)?{
	mut dest_path := site.book_path(path)
	dest_path.write(content)?
}

fn (mut site Site) template_install()?{

	if site.title == ""{
		site.title = site.name
	}

	//get embedded files to the mdbook dir
	for item in site.sites.embedded_files{		
		book_path := item.path.all_after_first("/")
		site.template_write(book_path,item.to_string() )?
	}

	c:=$tmpl("template/book.toml")
	site.template_write("book.toml",c)?




}