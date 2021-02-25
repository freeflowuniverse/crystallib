module tfgrid


fn test_basic(){

	ctx := Context{path:"/tmp/db"} 
	ctx.init()or {panic(err)}

	a_user := User{}

	// println(save<User>(&ctx, a_user))
	save2<User>(a_user) 
	panic("just_to_see_output")

}