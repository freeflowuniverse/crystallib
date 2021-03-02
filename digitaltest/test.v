module main

import despiegk.crystallib.digitaltwin

fn main() {
	mut twin := digitaltwin.factory(42) or { panic(err) }

	data := "Hello World"

	payload := twin.sign(data.bytes())
	println(payload)
}
