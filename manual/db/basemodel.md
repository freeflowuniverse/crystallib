
# basemodewl

## define a new model base on Base

```golang

import freeflowuniverse.crystallib.baobab.models.system

//inherit from the base class
pub struct MyStruct {
system.Base
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


```

## base model

the base model implements the following

```golang
struct Base {
	gid         smartid.GID
	params      paramsparser.Params
	version_base u8 = 1 //so we know how to do the serialize or unserialize
	serialization_type SerializationType
	name            string
	description     string
	remarks         Remarks
}

pub enum SerializationType{
	bin
	json
	script3
}

//remarks:

struct Remarks {
	remarks []Remark
}

struct Remark {
	content string
	time    ourtime.OurTime
	author  ?smartid.GID
	rtype RemarkType
	params paramsparser.Params
}

pub enum RemarkType{
	comment
	log
	audit
}


```

the base model has functionality for remarks, parameters, gid, name, description, ...

the serialization and deserrialization is done in the base model

## example how to use

this base model makes it easy to add properties to a base model, this can also be a complex type, see below an example how to use it

```golang

import freeflowuniverse.crystallib.baobab.smartid

mut m:=MyStruct{
        name:"aname"
        description:'a description\ncan be multiline\n1'
        gid:smartid.gid(oid_u32:99,cid_name:"test") or {panic(err)}
        color:"red"
        nr:8
    }

author_gid:=smartid.gid(oid_u32:333,cid_name:"test")or {panic(err)}

//parameters are being merged, the priority will end up to be low
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

//this will be the deserialzed object with the base information as well as the 2 new properties
println(m2)


```

