module encoderhero

import freeflowuniverse.crystallib.data.paramsparser
import time
import v.reflection

struct Person {
mut:
	name string
	age  ?int = 20
	// height f64
	// weight f64
	birthday time.Time
	deathday ?time.Time
	car      Car
	profiles []Profile
}

struct Car {
	name      string
	year      int
	insurance Insurance
}

struct Insurance {
	provider   string
	expiration time.Time
}

struct Profile {
	platform string
	url      string
}

const person_heroscript = "
!!define.person name:Bob birthday:'2012-12-12 00:00:00'
!!define.person.car name:'Bob\\'s car' year:2014
"

fn test_encode() ! {
	mut person := Person{
		name: 'Bob'
		age: 21
		birthday: time.new_time(
			day: 12
			month: 12
			year: 2012
		)
		car: Car{
			name: "Bob's car"
			year: 2014
		}
		profiles: [
			Profile{
				platform: 'Github'
				url: 'github.com/example'
			},
		]
	}
	person_script := encode[Person](person)!
	assert person_script.trim_space() == encoderhero.person_heroscript.trim_space()
}
