module model
import os

/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED

///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_factory.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

//there is a table per object type, holds path to sqlite and also the map to the data as cache
[heap]
pub struct Table {
pub mut:
	cache		map[int]&${name.capitalize()}
	path_data	string
	db_index 	sqlite.DB 			[skip]
	//this allows us to give the right id to an object
	id_last		int
}

[heap]
struct DataFactory {
pub mut:
	path_data string
	//keep map of cache for the objects
	@for name in model_names
	table_${name} Table${name.capitalize()}{
		db_index sqlite.DB{}
	}
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
	@{"df."}table_${name}_init(reset)?
	@end	


}

