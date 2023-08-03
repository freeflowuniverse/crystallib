module people

[heap]
pub struct MemDB {
	DBBase
pub mut:
	people       map[u32]&Person 
	groups       map[u32]&Group 
	countries    map[string]&Country
}

// creates a new global data structure
// ARGS:
pub fn new( [2]u32) MemDB {
	mut d := MemDB{}
	d.countries = people.countries_get()
	return d
}
