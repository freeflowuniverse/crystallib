//example from https://github.com/vlang/v/blob/master/doc/docs.md#generics trying to get it to work

struct User {
	tel int
	priority int
}


struct Post{
	message string
	priority int
}

const ( debug = true )

$if debug {
	println('DEBUG')
}

// struct Repo<T> {
//     db DB
// }

// fn new_repo<T>(db DB) Repo<T> {
//     return Repo<T>{db: db}
// }


// // $for method in T.methods {
// 	// $if method.return_type is Result {debug

// // This is a generic function. V will generate it for every type it's used with.
// fn (r Repo<T>) find_by_id(id int) {
//     table_name := T.name // in this example getting the name of the type gives us the table name
// 	println(table_name)
//     // return r.db.query_by_id(id,table_name)
// 	// return r.db.query_by_id<T>(id,table_name)  //was this not sure this is correct?
// 	//HOW now to do something usefull with the data of User & Post
// 	// return <T>{}
// }

// struct DB{
// 	name string
// }

// fn (mut e DB) query_by_id(i int, table_name string) string {
// 	return "test:$i:$table_name"
// }


// fn new_db(name string) DB{
// 	return DB{name:name}
// }

// db := new_db("test")
// users_repo := new_repo<User>(db) // returns Repo<User>
// posts_repo := new_repo<Post>(db) // returns Repo<Post>
// users_repo.find_by_id(1)
// user := users_repo.find_by_id(1)
// post := posts_repo.find_by_id(1)