module model
import os



///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_factory.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

[heap]
struct DataFactory {
pub mut:
	path_data string
mut:

  user    &User
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

	df.table_user_init(reset)?


}

