import despiegk.crystallib.timetools

fn test_base() {
	e := timetools.expiration_new('+1h') or { panic('cannot do expiration') }

	println(e)

	// panic("s")
}
