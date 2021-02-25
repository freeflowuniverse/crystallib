module tfgrid

// Note: T should be passed a struct name only
fn save<T>(ctx &Context, obj T) T {
	// println(T.name)
	return obj
}

fn save2<T>(obj T) {
	println(T.name)
	// return obj
}


// println(@LINE)




// //we can see if we can use Generics for this but last time didn't work as I wanted
// //idea is we have a generic way how to save/load from FS, best would be we don't have to repeat code
// //save object to filesystem
// pub fn {mut obj Group) set(context &Context) ?[]string{
// 	//store based on name, purpose is to have it user readable
// 	path := os.join_path(context.path,"group",obj.name)
// 	//use
// 	//json.encode_pretty(x voidptr) string
// }

// pub fn {mut obj Group) get(context &Context, id int) ?Group{
// 	//do a find
// 	path := os.join_path(context.path,"group",obj.name)

// }

// pub fn {mut obj Group) delete(context &Context, id int) ?{
// 	//do a find
// 	path := os.join_path(context.path,"group",obj.name)

// }

// pub fn {mut obj Group) exists(context &Context, id int) ?bool{
// 	//do a find
// 	path := os.join_path(context.path,"group",obj.name)

// }

// pub fn {mut obj Group) get_by_name(context &Context, name string) ?Group{
// 	path := os.join_path(context.path,"group",obj.name)

// }

// pub fn {mut obj Group) load(context &Context, id int) ?{
// 	//we walk over the data files
// 	//reset the index & rebuild in redis
// 	//check validity of each file (types): if error do nice error message

// }



// pub fn {mut obj Group) find(context &Context, id int) ?int{
// 	//lets do some caching in redis, so we have id to name map
// 	//but first time we need to read the objects and get the info and store mapping in redis

// }

