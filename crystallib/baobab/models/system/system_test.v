module system
import freeflowuniverse.crystallib.baobab.smartid

pub struct MyStruct {
Base
pub mut:
	color string
	nr int
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

	//TODO: do lots more tests


}

//todo: test the binary serialization / deserialization