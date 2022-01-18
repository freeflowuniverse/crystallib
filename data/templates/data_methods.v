// module data

/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED

///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn @object_new(id string) ?&@object_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.@objects{
		return df.@objects[id2]
	}
	mut obj := &@object_u{id:id2}
	df.@objects[id2] = obj
}

//get, if not found will give error
pub fn @object_get(id string) ?&@object_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.@objects{
		return df.@objects[id2]
	}
	return error("cannot find @object @id2")
}

//check the data obj exists
pub fn @object_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.@objects
}
