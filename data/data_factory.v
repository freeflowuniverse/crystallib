module data
import os
import texttools



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_factory.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

[heap]
struct DataFactory {
mut:
    users    map[string]&User
    circles    map[string]&Circle
    tasks    map[string]&Task
    issues    map[string]&Issue
    storys    map[string]&Story

}


fn init_data() &DataFactory {
	mut df := DataFactory{}
	return &df
}

const datafactory = init_data()

//init instance of planner
pub fn factory() &DataFactory {
	// reuse single object
	return datafactory
}


############################################

// module data



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn user_new(id string) ?&user_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.users{
		return df.users[id2]
	}
	mut obj := &user_u{id:id2}
	df.users[id2] = obj
}

//get, if not found will give error
pub fn user_get(id string) ?&user_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.users{
		return df.users[id2]
	}
	return error("cannot find user @id2")
}

//check the data obj exists
pub fn user_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.users
}

############################################

// module data



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn circle_new(id string) ?&circle_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.circles{
		return df.circles[id2]
	}
	mut obj := &circle_u{id:id2}
	df.circles[id2] = obj
}

//get, if not found will give error
pub fn circle_get(id string) ?&circle_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.circles{
		return df.circles[id2]
	}
	return error("cannot find circle @id2")
}

//check the data obj exists
pub fn circle_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.circles
}

############################################

// module data



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn task_new(id string) ?&task_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.tasks{
		return df.tasks[id2]
	}
	mut obj := &task_u{id:id2}
	df.tasks[id2] = obj
}

//get, if not found will give error
pub fn task_get(id string) ?&task_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.tasks{
		return df.tasks[id2]
	}
	return error("cannot find task @id2")
}

//check the data obj exists
pub fn task_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.tasks
}

############################################

// module data



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn issue_new(id string) ?&issue_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.issues{
		return df.issues[id2]
	}
	mut obj := &issue_u{id:id2}
	df.issues[id2] = obj
}

//get, if not found will give error
pub fn issue_get(id string) ?&issue_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.issues{
		return df.issues[id2]
	}
	return error("cannot find issue @id2")
}

//check the data obj exists
pub fn issue_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.issues
}

############################################

// module data



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_methods.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//add, id can be the name
pub fn story_new(id string) ?&story_u {
	mut id2 := id
	id2 = texttools.name_fix(id)
	mut df := factory()
	if id2 in df.storys{
		return df.storys[id2]
	}
	mut obj := &story_u{id:id2}
	df.storys[id2] = obj
}

//get, if not found will give error
pub fn story_get(id string) ?&story_u {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)
	if id2 in df.storys{
		return df.storys[id2]
	}
	return error("cannot find story @id2")
}

//check the data obj exists
pub fn story_exists(id string) bool {
	mut df := factory()
	mut id2 := id
	id2 = texttools.name_fix(id)	
	return id2 in df.storys
}
