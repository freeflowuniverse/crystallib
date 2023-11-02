module system

import json
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.baobab.smartid

[heap]
pub struct Base {
pub mut:
	gid                smartid.GID
	params             paramsparser.Params
	version_base       u8 = 1 // so we know how to do the serialize or unserialize
	serialization_type SerializationType
	name               string
	description        string
	remarks            Remarks
}

pub enum SerializationType {
	bin
	json
	tscript
}

pub fn (mut o Base) json() string {
	return json.encode(o)
}

pub fn serializationtype_u8(t SerializationType) u8 {
	match t {
		.bin { return 0 }
		.json { return 1 }
		.tscript { return 2 }
	}
	return 255
}

pub fn (mut o Base) params_set(text string) ! {
	o.params = paramsparser.new(text)!
}

// will merge the params
pub fn (mut o Base) params_add(text string) ! {
	o.params.merge(text)!
}

// returns bin encoder already populated with all base properties
pub fn (o Base) bin_encoder() !encoder.Encoder {
	mut b := encoder.new()
	b.add_u8(o.version_base) // remember which version this is	
	b.add_string(o.gid.str())
	b.add_string(o.params.str())
	b.add_string(o.name)
	b.add_string(o.description)
	b.add_bytes(o.remarks.serialize_binary())

	return b
}

pub fn base_decoder(data []u8) !(encoder.Decoder, Base) {
	mut o := Base{}
	mut d := encoder.decoder_new(data)
	assert d.get_u8() == 1
	o.gid = smartid.gid(gid_str: d.get_string())!
	o.params = paramsparser.new(d.get_string())!
	o.name = d.get_string()
	o.description = d.get_string()
	remarksbytes := d.get_bytes()
	o.remarks = remarks_unserialize_binary(remarksbytes)!
	o.serialization_type = .bin
	return d, o
}
