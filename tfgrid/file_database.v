module tfgrid

//check/load the db
//does not load the objects in memory, only checks the validity and load the index in redis
pub fn db_load(context &Context, id int) ?{
	//we walk over the data files of all different types
	//for each type call the load action
}

