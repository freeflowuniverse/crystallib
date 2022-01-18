module main
import os

const codepath_file = @FILE

const model_name = ["user","circle","task","issue","story"]

fn  main() {

	dirpath := os.dir(codepath_file)


	//initial template
	templatepath := "${dirpath}/templates/data_factory.v"

	mut out := os.read_file(templatepath) or  {panic("canont read file $templatepath")}

	force := true
	mut objitems := ""

	for name in model_name{
		out += "\n############################################\n\n" + template(name,force)
		//this is to replace for the factory, its called @ITEMS, its to remember the different objects
		objitems += "    ${name}s    map[string]&${name.capitalize()}\n"		
	}

	out = out.replace("@ITEMS",objitems)

	out = out.replace("/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED","")

	outpath := "${dirpath}/data_factory.v"
	os.write_file(outpath,out) or {panic("cannot write file $outpath")}	

}

fn template(name string, force bool) string{

	dirpath := os.dir(codepath_file)

	templatepath := "${dirpath}/templates/data_methods.v"
	templatepath2 := "${dirpath}/templates/data_obj.v"

	mut toreplace := map[string]string{}
	mut txt := os.read_file(templatepath) or  {panic("canont read file $templatepath")}
	
	toreplace["object"]=name
	toreplace["Object"]=name.capitalize()
	toreplace["objects"]=name+"s"
	toreplace["Objects"]=name.capitalize()+"s"

	mut keys := toreplace.keys()
	keys.sort()
	keys = keys.reverse()//this should put biggest ones first

	for key in keys{
		txt = txt.replace("@${key}",toreplace[key])
	}

	mut txt2 := os.read_file(templatepath2) or  {panic("canont read file $templatepath2")}
	for key in keys{
		txt2 = txt2.replace("@${key}",toreplace[key])
	}	
	txt2 = txt2.replace("/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED","")
	modelfilepath := "${dirpath}/${name}_model.v"
	if ! os.exists(modelfilepath) || force{
		os.write_file(modelfilepath,txt2) or {panic("cannot write file $modelfilepath")}
	}
	
	return txt

}


// fn  main() {
// 	force := true
// 	togenerate := ["user","circle"]
// 	dirpath := os.dir(codepath_file)
// 	println(dirpath)
// 	for name in togenerate{
// 		methodfilepath := "${dirpath}/${name}_methods.v"
// 		if os.exists(methodfilepath) && ! force{
// 			continue
// 		}
// 		object :=  name
// 		object_u := name.capitalize()
// 		objects :=  name+"s"
// 		objects_u := name.capitalize()+"s"
// 		// mut txt := $tmpl('data_obj.v\')
// 		// mut txt := $tmpl("data_methods.v\")
// 		mut txt := $tmpl("data_obj.v\")
	
// 		txt = txt.replace("/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED","")
// 		println(txt)
// 		os.write_file(methodfilepath,txt) or {panic("canont write file $methodfilepath")}
// 	}
// 	//data_obj.v\
// }
