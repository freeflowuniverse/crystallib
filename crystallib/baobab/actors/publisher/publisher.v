module publisher

// collection methods
pub fn (mut p Publisher[Config]) new_collection(collection Collection) !u32 {
	return p.backend.new[Collection](collection)!
}

pub fn (mut p Publisher[Config]) get_collection(id u32) !Collection {
	return p.backend.get[Collection](id)!
}

pub fn (mut p Publisher[Config]) set_collection(collection Collection) ! {
	p.backend.set[Collection](collection)!
}

pub fn (mut p Publisher[Config]) delete_collection(id u32) ! {
	p.backend.delete[Collection](id)!
}

// template methods
pub fn (mut p Publisher[Config]) new_template(template Template) !u32 {
	return p.backend.new[Template](template)!
}

pub fn (mut p Publisher[Config]) get_template(id u32) !Template {
	return p.backend.get[Template](id)!
}

pub fn (mut p Publisher[Config]) set_template(template Template) ! {
	p.backend.set[Template](template)!
}

pub fn (mut p Publisher[Config]) delete_template(id u32) ! {
	p.backend.delete[Template](id)!
}
