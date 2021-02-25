module planner


pub struct DB {
pub mut:
	issues 		 map[string]int

}


struct Repo<T> {
    db DB
}

fn new_repo<T>(db DB) Repo<T> {
    return Repo<T>{db: db}
}

// This is a generic function. V will generate it for every type it's used with.
fn (r Repo<T>) find_by_id(id int) ?T {

}


db := DB{}
users_repo := new_repo<User>(db) // returns Repo<User>
posts_repo := new_repo<Post>(db) // returns Repo<Post>
user := users_repo.find_by_id(1)? // find_by_id<User>
post := posts_repo.find_by_id(1)? // find_by_id<Post>