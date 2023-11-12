module main

import freeflowuniverse.crystallib.core.pathlib

const templatespath = os.dir(@FILE) + '/templates'
const outpath = os.dir(@FILE) + '/elements'

[params]
struct ElementCat{
	name string
	classname string
}

fn new(args_ ElementCat)ElementCat{
	mut args:=args_
	if args.classname==""{

	}
}


fn do() ! {

	mut elements:=[]ElementCat{}

	elements<<new(name:"html")


	content:=$templ("${templatespath}/generated.v")
	mut outpath:=pathlib.get_file(path:"${outpath}/generated.v",create:true)!
	outpath.write(content)!

}

fn main() {
	do() or { panic(err) }
}
