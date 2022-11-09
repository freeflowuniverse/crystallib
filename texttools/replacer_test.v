module texttools

fn test_replacer() {
	mut text := '
	these; Are Some ramdom words!
	blue lagoon
	Blue lagoon
	blue_lagoon
	blue_Lagoon
	blue_Lagoon s
	blue_Lagoons
	lagoon
    blueLagoon
	&redlagoon

	'

	replacer := {
		'Lagoon':'Green Lagoon'
		'blue_lagoon':'Red Lagoon'		
	}

	mut result_required := '
	these; Are Some ramdom words!
	blue Green Lagoon
	Blue Green Lagoon
	Red Lagoon
	Red Lagoon
	Red Lagoon s
	Red Lagoons
	Green Lagoon
	Red Lagoon
	&redlagoon
	'

	r := replace_items(dedent(text),replacer)

	a := dedent(r).trim(' \n')
	b := dedent(result_required).trim(' \n')

	assert a==b

}

// fn test_replacer2() {
// 	mut text := '
// 	these; Are Some ramdom words!
// 	blue lagoon
// 	Blue [blue_lagoon](blue_lagoon) lagoons n
// 	blue_lagoon
// 	blue_Lagoon (blue_Lagoon) test
// 	blue_Lagoon s
// 	blue_Lagoons
// 	lagoon
//     blueLagoon
// 	&redlagoon

// 	'

// 	replacer := {
// 		'Lagoon':'Green Lagoon'
// 		'blue_lagoon':'Red Lagoon'		
// 	}

// 	mut result_required := '
// 	these; Are Some ramdom words!
// 	blue Green Lagoon
// 	Blue [blue_lagoon](blue_lagoon) Green Lagoons n
// 	Red Lagoon
// 	Red Lagoon (Red Lagoon) test
// 	Red Lagoon s
// 	Red Lagoons
// 	Green Lagoon
// 	Red Lagoon
// 	&redlagoon
// 	'

// 	r := replace_items(dedent(text),replacer)

// 	a := dedent(r).trim(' \n')
// 	b := dedent(result_required).trim(' \n')

// 	println(a)
// 	println(b)

// 	assert a==b

// }

// fn test_replacer3() {
// 	mut text := '
// 	More info see https://en.wikipedia.org/wiki/Peer-to-peer
// 	blue
// 	'

// 	replacer := {
// 		'peer-to-peer':'PEERPEER'
// 		'blue':'Red Lagoon'		
// 	}

// 	mut result_required := '

// 	'

// 	r := replace_items(dedent(text),replacer)

// 	a := dedent(r).trim(' \n')
// 	b := dedent(result_required).trim(' \n')

// 	println(a)
// 	println(b)

// 	assert a==b

// }

fn test_replacer4() {
	mut text := '
	- [Why](threefold__why_intro.md)
		- [Web 4.0](tfgrid__web4.md)
		- [Why we do what we do](threefold__why_intro.md)
		- [Why a new P2P cloud](threefold__why_grid_link.md)
	'

	replacer := {
		'tfgrid__web4': 'PEERPEER'
		'P2P':          'Red Lagoon'
	}

	mut result_required := '
	- [Why](threefold__why_intro.md)
		- [Web 4.0](tfgrid__web4.md)
		- [Why we do what we do](threefold__why_intro.md)
		- [Why a new P2P cloud](threefold__why_grid_link.md)
	'

	r := replace_items(dedent(text), replacer)

	a := dedent(r).trim(' \n')
	b := dedent(result_required).trim(' \n')

	println(a)
	println(b)

	assert a == b
}
