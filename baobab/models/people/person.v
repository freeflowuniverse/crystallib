module people

import freeflowuniverse.protocolme.models.system
import json
import freeflowuniverse.crystallib.encoder

[heap]
pub struct Person {
	system.Base
pub mut:
	id          string // needs to be unique
	firstname   string
	lastname    string
	description string
	start_date  system.OurTime
	end_date    system.OurTime
	contacts    Contacts
}

pub struct PersonNewArgs {
pub mut:
	firstname   string [required]
	lastname    string [required]
	description string
}

// ## Add Contact Information
//
// ### ARGS:
//
// - firstname string
// - lastname string
// - description string
pub fn (mut person Person) contact_add() !&Contact {
	mut o := Contact{
		firstname: person.firstname
		lastname: person.lastname
		description: person.description //? How to set this as optional if description not given
	}
	// person.contact << o
	return &o
}

pub fn person_new(data string) ?Person {
	if data != '' {
		obj := json.decode(Person, data) or {
			return error('Failed to decode json, error: ${err} for ${data}')
		}
		return obj
	}
	return Person{}
}

pub fn (mut o Person) bin_encoder() !encoder.Encoder {
	// mut b:=o.respbuilder()!
	// b.add(resp.r_list_string([o.id, o.firstname,o.lastname, o.description]))
	// b.add(resp.r_list_int([o.start_date.int(),o.end_date.int()]))
	// return b.data.bytestr()
}

pub fn (mut o Person) json() string {
	return json.encode(o)
}

pub fn (mut o Person) contacts() ![]Contact {
}
