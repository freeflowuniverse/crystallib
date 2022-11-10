module main

import os

const codepath_file = @FILE

// const model_names = ["user","circle","task","issue","story"]
const model_names = ['user']

fn clean(txt string) string {
	txt2 := txt.replace('/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED', '')
	return txt2
}

fn main() {
	force := true
	dirpath := os.dir(codepath_file)
	println(dirpath)
	os.mkdir_all('$dirpath/model')?
	mut factory_methods_txt := ''
	for name2 in model_names {
		name := name2
		methodfilepath := '$dirpath/model/${name}_model.v'
		if os.exists(methodfilepath) && !force {
			continue
		}
		methodfilepath2 := '$dirpath/model/${name}_model0.v'
		mut txt := $tmpl('templates/data_obj.v')
		os.write_file(methodfilepath, clean(txt)) or { panic('cannot write file $methodfilepath') }
		mut txt2 := $tmpl('templates/data_obj0.v')
		os.write_file(methodfilepath2, clean(txt2)) or {
			panic('cannot write file $methodfilepath2')
		}
	}
	mut txt_data_factory := $tmpl('templates/data_factory.v')

	os.write_file('$dirpath/model/factory_models.v', clean(txt_data_factory)) or {
		panic('canont write file factory_models')
	}

	// data_obj.v\
}
