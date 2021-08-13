module main

struct GitStructure {
pub mut:
	a int
	b string
}

fn init_codewww() GitStructure {
	mut gitstructure := GitStructure{}
	return gitstructure
}

const codecache = init_codewww()

pub fn get() &GitStructure {
	println('OBJ: $codecache')
	return &codecache
}

fn main() {
	mut r := get()
	r.a = 10
	println(r)

	mut r2 := get()
	// was hoping that r.a was still set, but it isn't
	println(r2)
}
