module hoteldb

type Product = Beverage | Food | Room | Boat

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

