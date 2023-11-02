module system

import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.paramsparser

[heap]
pub struct Remarks {
pub mut:
	remarks []Remark
}

[heap]
pub struct Remark {
pub mut:
	content string
	time    ourtime.OurTime
	author  ?smartid.GID
	rtype   RemarkType
	params  paramsparser.Params
}

pub enum RemarkType {
	comment
	log
	audit
}

pub fn remarktype_u8(t RemarkType) u8 {
	match t {
		.comment { return 0 }
		.log { return 1 }
		.audit { return 2 }
	}
	return 255
}

pub fn remarktype(t u8) RemarkType {
	match t {
		0 { return .comment }
		1 { return .log }
		2 { return .audit }
		else { return .comment }
	}
	return .comment
}

pub fn (mut o Remark) params_set(text string) ! {
	o.params = paramsparser.new(text)!
}

// will merge the params
pub fn (mut o Remark) params_add(text string) ! {
	o.params.merge(text)!
}

[heap]
struct RemarkAddArgs {
pub mut:
	content string
	time    ?ourtime.OurTime
	author  ?smartid.GID
	rtype   RemarkType
	params  string
}

pub fn (mut o Base) remark_add(args_ RemarkAddArgs) !Remark {
	return o.remarks.remark_add(args_)!
}

pub fn (mut o Remarks) remark_add(args_ RemarkAddArgs) !Remark {
	mut args := args_
	time_obj := args.time or { ourtime.new('')! }
	mut r := Remark{
		content: args.content
		time: time_obj
		author: args.author
		rtype: args.rtype
		params: paramsparser.parse(args.params.str())!
	}
	o.remarks << r

	return r
}

pub fn (o Remark) serialize_binary() []u8 {
	mut b := encoder.new()
	b.add_u8(1) // remember which version this is	
	b.add_u8(remarktype_u8(o.rtype))
	b.add_string(o.content)
	b.add_int(o.time.int())
	agid := o.author or { smartid.GID{} }
	b.add_string(agid.str())
	b.add_string(o.params.str())
	return b.data
}

pub fn (o Remarks) serialize_binary() []u8 {
	mut b := encoder.new()
	b.add_u8(1) // remember which version this is	
	b.add_u16(u16(o.remarks.len))
	for remark in o.remarks {
		b.add_bytes(remark.serialize_binary())
	}
	return b.data
}

pub fn remark_unserialize_binary(data []u8) !Remark {
	mut remark := Remark{}
	mut d := encoder.decoder_new(data)
	assert d.get_u8() == 1 // remember which version this is	
	remark.rtype = remarktype(d.get_u8())
	remark.content = d.get_string()
	remark.time = ourtime.OurTime{
		unix: i64(d.get_int())
	}

	gid_str := d.get_string()
	if gid_str != '0.0' {
		remark.author = smartid.gid(gid_str: gid_str)!
	}
	remark.params = paramsparser.new(d.get_string())!
	return remark
}

pub fn remarks_unserialize_binary(data []u8) !Remarks {
	mut remarks := Remarks{}
	mut d := encoder.decoder_new(data)
	assert d.get_u8() == 1 // remember which version this is	
	l := d.get_u16()
	for _ in 0 .. l {
		// get the right amount of remarks back
		data_remark := d.get_bytes()
		remark := remark_unserialize_binary(data_remark)!
		remarks.remarks << remark
	}
	return remarks
}

[params]
pub struct FindRemarkArgs {
	params_filter ?string
	author        ?smartid.GID
	time_from     ?ourtime.OurTime
	time_to       ?ourtime.OurTime
}

pub fn (remarks Remarks) find_remark(args FindRemarkArgs) ![]Remark {
	mut res := []Remark{}
	for remark in remarks.remarks {
		if p := args.params_filter {
			if !remark.params.filter_match_item(p)! {
				continue
			}
		}

		if p := args.author {
			if a := remark.author {
				if a != p {
					continue
				}
			} else {
				continue
			}
		}

		if p := args.time_from {
			if remark.time.unix_time() < p.unix_time() {
				continue
			}
		}

		if p := args.time_to {
			if remark.time.unix_time() > p.unix_time() {
				continue
			}
		}

		res << remark
	}

	return res
}
