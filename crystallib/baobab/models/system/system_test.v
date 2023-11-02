module system
import freeflowuniverse.crystallib.baobab.smartid

pub struct MyStruct {
Base
pub mut:
	color string
	nr int
}

//example of how we should implement binary serialization
pub fn (o MyStruct) serialize_binary() ![]u8{
	mut b:=o.bin_encoder()!
	b.add_string(o.color)
	b.add_int(o.nr)
	return b.data
}

pub fn load(data []u8) !MyStruct{
	mut d,base:=base_decoder(data)!
	mut o:=MyStruct{Base:base}
	o.color=d.get_string()
	o.nr=d.get_int()
	return o
}


fn test_base() {

	mut m:=MyStruct{
			name:"aname"
			description:'a description\ncan be multiline\n1'
			gid:smartid.gid(oid_u32:99,cid_name:"test") or {panic(err)}
			color:"red"
			nr:8
		}

	author_gid:=smartid.gid(oid_u32:333,cid_name:"test")or {panic(err)}

	m.params_add("priority:urgent silver") or {panic(err)}
	m.params_add("priority:low gold") or {panic(err)}
	m.params_add("timing:now gold") or {panic(err)}

	m.remark_add(
		author:author_gid
		content:"
			lucky we did do this
			can be multiline
		"
		rtype:.audit
		) or {panic(err)}

	m.remark_add(
		content:"
			another one
		"
		rtype:.log
		params:"color:red urgent"
		) or {panic(err)}

	println(m)

	data:=m.serialize_binary() or {panic(err)}
	m2:=load(data) or {panic(err)}

	println(m2)
	
	if true{
		panic('55ss')
	}
	//TODO: do lots more tests


}

