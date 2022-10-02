module main

import freeflowuniverse.crystallib.pathlib

fn do() ? {

	mut test:=[]pathlib.Path{}
	test << pathlib.get("/test/a/b/c/d")
	test << pathlib.get("/test/a/")
	res:=pathlib.find_common_ancestor(test) or {panic("test anncestor.$err")}
	assert res=="/test/a"


	test=[]pathlib.Path{}
	test << pathlib.get("test/a/b/c/d")
	test << pathlib.get("test/a/")
	res2:=pathlib.find_common_ancestor(test) or {panic("test anncestor.$err")}
	// assert res2=="/Users/despiegk1/code4/books/content/mytwin/skills/creativity/img/test/a"


	println(res2)
	panic("s")
	

}

fn main() {
	do() or { panic(err) }
}
