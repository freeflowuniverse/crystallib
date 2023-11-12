module main

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

const templatespath = os.dir(@FILE) + '/templates'
const outpath = os.dir(@FILE) + '/elements'

[params]
struct ElementCat{
	name string
	classname string
}

fn new(args_ ElementCat)ElementCat{
	mut args:=args_
	args.name = texttools.name_fix(args.name)
	if args.classname==""{
		args.classname=args.name[0].to_upper()
		args.classname+=args.name[1..]
		if args.classname.contains("_"){
			panic("Cannot have _ name if classname not specified.")
		}
	}	
}


fn do() ! {

	mut elements:=[]ElementCat{}

	elements<<new(name:"html")


	// e.g.	type DocElement = Action | CodeBlock | Text | None
	mut elementtypes:=""
	for element in elements{
		elementtypes+= "${element.classname} | "
	}
	elementtypes=elementtypes.trim_right(" |")


	content:=$tmpl("${templatespath}/generated.vtemplate")
	mut outpath:=pathlib.get_file(path:"${outpath}/generated.",create:true)!
	outpath.write(content)!

	for element in elements{
		content2:=$tmpl("${templatespath}/element_x.vtemplate")
		mut outpath2:=pathlib.get_file(path:"${outpath}/element_${element.name}.v",create:true)!
		outpath2.write(content2)!		
	}

}

fn main() {
	do() or { panic(err) }
}
