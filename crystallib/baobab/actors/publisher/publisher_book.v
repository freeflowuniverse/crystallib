module publisher

// book methods
pub fn (mut p Publisher[Config]) new_book(book Book) !u32 {
	return p.backend.new[Book](book)!
}

pub fn (mut p Publisher[Config]) get_book(id u32) !Book {
	return p.backend.get[Book](id)!
}

pub fn (mut p Publisher[Config]) set_book(book Book) ! {
	p.backend.set[Book](book)!
}

pub fn (mut p Publisher[Config]) delete_book(id u32) ! {
	p.backend.delete[Book](id)!
}