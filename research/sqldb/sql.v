module sqldb

//lets do DB per Circle (sqlite)

pub struct KVTable {
pub mut:
	key u32 //we use the int representation of our SID, autoincrement
	value string
}

//params are expanded to this
pub struct SearchTable {
pub mut:
	name string
	val string //empty if only argument
	key u32 //link to the id in KVTable
}



//we need a global to get access to sqldb, we will have to test in threads and co-routines