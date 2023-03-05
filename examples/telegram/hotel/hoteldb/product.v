module hoteldb

type Product = Beverage | Boat | Food | Room

pub enum ProductState {
	ok
	planned
	unavailable
	endoflife
	error
}
