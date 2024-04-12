module encoderhero

import freeflowuniverse.crystallib.data.paramsparser
import time
import v.reflection

struct Person {
mut:
	name     string
	age      ?int = 20
	birthday time.Time
	deathday ?time.Time
}

fn test_encode() ! {
	mut person := Person{
		name: 'Bob'
		birthday: time.now()
	}
	person_json := encoderhero.encode[Person](person)!
	panic('dubby \n${person_json}')
}