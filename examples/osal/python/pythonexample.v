module main

import freeflowuniverse.crystallib.osal.python
import  json

fn main() {
	do1() or { panic(err) }
}

pub struct Person {
    name     string
    age      int
    is_member bool
    skills   []string
}



fn do1() ! {


	mut py:=python.new(name:'test')! //a python env with name test
	py.update()!
	py.pip("ipython")!

	cmd:=$tmpl("pythonexample.py")
	// for i in 0..100{
	// 	println(i)
	// 	res:=py.exec(cmd:cmd)!
	// }
	res:=py.exec(cmd:cmd)!

	person:=json.decode(Person,res)!
	println(person)

}

