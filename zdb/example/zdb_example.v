

module main
import freeflowuniverse.crystallib.zdb

fn do() ! {
	mut zdb := zdb.get("/Users/despiegk1/zdb","1234","test")!
	i:=zdb.nsinfo()!
	println(i)
}

fn main() {
	do() or { panic(err) }
}
