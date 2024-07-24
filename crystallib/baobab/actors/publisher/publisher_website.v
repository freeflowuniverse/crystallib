module publisher

pub fn (mut p Publisher[Config]) new_website(website Website) !u32 {
	return p.backend.new[Website](website)!
}

pub fn (mut p Publisher[Config]) get_website(id u32) !Website {
	return p.backend.get[Website](id)!
}

pub fn (mut p Publisher[Config]) set_website(website Website) ! {
	p.backend.set[Website](website)!
}

pub fn (mut p Publisher[Config]) delete_website(id u32) ! {
	p.backend.delete[Website](id)!
}

pub fn (mut p Publisher[Config]) list_website() ![]Website {
	return p.backend.list[Website]()!
}

pub fn (mut p Publisher[Config]) website_add_section(mut website Website, section Section) ! {
	website.sections << section
}

pub fn (mut p Publisher[Config]) website_add_page(mut website Website, page Page) ! {
	website.pages << page
}