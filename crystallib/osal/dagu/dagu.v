module dagu

// import freeflowuniverse.crystallib.osal

@[heap]
pub struct Dagu {
pub mut:
	config Config
}


pub fn new() !Dagu {
	mut obj := Dagu{
	}

	return obj
}

