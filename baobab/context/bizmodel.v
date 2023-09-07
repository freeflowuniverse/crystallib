module context

import freeflowuniverse.crystallib.bizmodel
import freeflowuniverse.crystallib.texttools


pub fn (mut c Context) bizmodel(name_ string) !bizmodel.BizModel {
	name:=texttools.name_fix(name_)
	if !(name in c.bizmodels){
		return error("Cannot find bizmodel with name '${name}'")
	}
	return c.bizmodels[name] or {panic(err)}
}


pub fn (mut c Context) bizmodel_add(name string, path string) ! {

	c.bizmodels[name] = bizmodel.new(path:path,context:c)!	

}


fn (mut c Context) bizmodel_init(mut actions Actions, action Action) ! {


		c.bizmodels[name] = bizmodel.new()!	
	}else{


}