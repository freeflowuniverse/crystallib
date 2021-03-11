module main

fn main(){


	mut r := map{"a":"aaa"}

	r[""]="a"
	r["b"]="b1"

	println(r)

	assert !("c" in r)
	assert ("a" in r)

	if "a" in r{
		println("aaaa")
	}

}