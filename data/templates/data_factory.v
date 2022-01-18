module data
import os
import texttools

/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED

///////IMPORTANT DO NOT MODIFY THIS FILE, THIS FILE IS GENERATED FROM TEMPLATE 'data_factory.v', code changes need to be do there and re-run generate.v
///////JUST REMOVE THIS FILE IF YOU WANT IT TO BE REGENERATED

[heap]
struct DataFactory {
mut:
@ITEMS
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

