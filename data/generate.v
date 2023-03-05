module data

// import os

const codepath_file = @FILE

// const model_names = ["user","circle","task","issue","story"]
const model_names = ['user']

fn clean(txt string) string {
	txt2 := txt.replace('/////////// THIS IS THE TEMPLATE, THIS CAN BE MODIFIED', '')
	return txt2
}

pub fn generate(path_in string, path_out string) !CodeGenerator {
	mut generator := new(path_in, path_out)!
	generator.scan()!
	generator.process()!
	generator.generate()!
	return generator
}

// mut factory_methods_txt := ''
// for name2 in model_names {
// 	mut name:=name2
<<<<<<< HEAD
// 	methodfilepath := '$dirpath/model/${name}_model.v'
// 	if os.exists(methodfilepath) && !force {
// 		continue
// 	}
// 	methodfilepath2 := '$dirpath/model/${name}_model0.v'
// 	mut txt := $tmpl('templates/data_obj.v')
// 	os.write_file(methodfilepath, clean(txt)) or { panic('cannot write file $methodfilepath') }
// 	mut txt2 := $tmpl('templates/data_obj0.v')
=======
// 	methodfilepath := '$dirpath/model/${name}_model.vtemplate'
// 	if os.exists(methodfilepath) && !force {
// 		continue
// 	}
// 	methodfilepath2 := '$dirpath/model/${name}_model0.vtemplate'
// 	mut txt := $tmpl('templates/data_obj.vtemplate')
// 	os.write_file(methodfilepath, clean(txt)) or { panic('cannot write file $methodfilepath') }
// 	mut txt2 := $tmpl('templates/data_obj0.vtemplate')
>>>>>>> 667df183094470ef5dbeba569d84a1ac2b27784e
// 	os.write_file(methodfilepath2, clean(txt2)) or {
// 		panic('cannot write file $methodfilepath2')
// 	}
// }
<<<<<<< HEAD
// mut txt_data_factory := $tmpl('templates/data_factory.v')

// os.write_file('$dirpath/model/factory_models.v', clean(txt_data_factory)) or {
// 	panic('canont write file factory_models')
// }

// data_obj.v
=======
// mut txt_data_factory := $tmpl('templates/data_factory.vtemplate')

// os.write_file('$dirpath/model/factory_models.vtemplate', clean(txt_data_factory)) or {
// 	panic('canont write file factory_models')
// }

// data_obj.vtemplate
>>>>>>> 667df183094470ef5dbeba569d84a1ac2b27784e
