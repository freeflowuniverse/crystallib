module main

import freeflowuniverse.crystallib.osal.python


fn do1() ! {

py:=python.new(name:'test')! //a python env with name test
py.update()!
py.pip("ipython")!



}

fn main() {
	do1() or { panic(err) }
}
