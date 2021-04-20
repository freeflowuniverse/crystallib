// example from https://github.com/vlang/v/blob/master/doc/docs.md#generics trying to get it to work

// struct User {
// 	tel      int
// 	priority int
// }

// struct Post {
// 	message  string
// 	priority int
// }

// const (
// 	debug = true
// )

// $if debug {
// 	println('DEBUG')
// }

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

struct DB{
	name string
}

// pub fn (mut db DB) query_one<T>(query string, id int) ?T {
// 	return T
// }


struct Repo<T> {
    db DB
}

struct User {
	id   int
	name string
}

struct Post {
	id   int
	user_id int
	title string
	body string
}

fn new_repo<T>(db DB) Repo<T> {
    return Repo<T>{db: db}
}

// This is a generic function. V will generate it for every type it's used with.
fn (r Repo<T>) find_by_id(id int) ? {
	println(T{})
    table_name := T.name // in this example getting the name of the type gives us the table name
	println(table_name)
    // return r.db.query_one<T>('select * from $table_name where id = ?', id)
	e := T{}
	return e
}

db := DB{}
users_repo := new_repo<User>(db) // returns Repo<User>
posts_repo := new_repo<Post>(db) // returns Repo<Post>


user := users_repo.find_by_id(1)? // find_by_id<User>
post := posts_repo.find_by_id(1)? // find_by_id<Post>