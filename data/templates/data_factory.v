module model
import os

/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED

///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_factory.v'
///////code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED


[heap]
struct DataFactory {
pub mut:
	path_data string
	//keep map of cache for the objects
	@for name3 in model_names
	${name3} &Table${name3.capitalize()}
	@end		
}

pub struct ArgModelGet {
pub mut:
	id 	 int
	name string
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

pub fn (mut df DataFactory) init(path_data string, reset bool)?  {
	df.path_data = path_data
	@for name in model_names
	path0 := df.path_data+"/${name}"
	mut table_${name} := Table${name.capitalize()}{
		path_data : path0
		factory : &df
		db_index : db
	}	



	@{"df."}table_${name}_init(reset)?
	@end	


}

