module main
import os
import freeflowuniverse.crystallib.bizmodel

const testpath = os.dir(@FILE) + '/data'

fn do() ! {
	
	mut m:=bizmodel.new(path:testpath)!

	println(m)

}

fn main() {
	do() or { panic(err) }
}