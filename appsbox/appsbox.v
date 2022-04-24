module appsbox

import os
import rootpath


[heap]
pub struct AppsBox {
pub mut:
	apps []App
	apps_path string
	bin_path string
	var_path string
}

fn init_factory() AppsBox {
	mut apps := AppsBox{}
	return apps
}

// Singleton creation
const factory = init_factory()

pub fn init(path string){
	mut apps := appsbox.factory
	apps.home_set(path)
}

fn singleton() &AppsBox{
	return &appsbox.factory
}

pub fn get() &AppsBox{
	mut apps := singleton()
	if apps.apps_path == "" {
		apps.home_set("")
	}
	return apps
}

//set home directory and do initialization of multiple parts
fn (mut apps AppsBox) home_set (path_ string){
	mut path:= path_
	if path==""{
		// path="~/hub3"
		path = rootpath.default_path()
	}
	if apps.apps_path == ""{
		apps.apps_path = path
	}
	if apps.bin_path == ""{
		apps.bin_path = "${apps.apps_path}/bin"
	}
	if apps.var_path == ""{
		apps.var_path = "${apps.apps_path}/var"
	}
	apps.apps_path = apps.apps_path.replace("~",os.home_dir())
	if ! os.exists(apps.apps_path){
		os.mkdir_all(apps.apps_path) or {panic("cannot create apps_path")}
	}		
	apps.bin_path = apps.bin_path.replace("~",os.home_dir())
	if ! os.exists(apps.bin_path){
		os.mkdir_all(apps.bin_path) or {panic("cannot create bin_path")}
	}		
	apps.var_path = apps.var_path.replace("~",os.home_dir())
	if ! os.exists(apps.var_path){
		os.mkdir_all(apps.var_path) or {panic("cannot create var_path")}
	}		
		
}
