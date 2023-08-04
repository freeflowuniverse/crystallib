module people

import freeflowuniverse.protocolme.models.system
import json

fn test_1() {
	mut p := person_new('')?
	p.start_date.now()

	println(p)
	mut y := p.respbuilder()!
	println(y)
	println(p.json())

	panic('s')
}
