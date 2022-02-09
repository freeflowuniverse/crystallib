module appsbox

import os

[heap]
pub struct AppsBox {
pub mut:
	apps map[string]&App
	bin_path string = "~/hub3/bin"
}

fn init_factory() AppsBox {
	mut apps := AppsBox{}
	apps.bin_path = apps.bin_path.replace("~",os.home_dir())
	if ! os.exists(apps.bin_path){
		os.mkdir_all(apps.bin_path) or {panic("cannot create apps binpath")}
	}		
	return apps
}

// Singleton creation
const factory = init_factory()

pub fn new() &AppsBox{
	return &appsbox.factory
}

pub fn (mut apps AppsBox) get(name string) &App{
	mut f:= new()
	if !(name in f.apps){
		mut app := App{
			name: name
			// path: "${apps.bin_path}/$name"
		}
		f.apps[name] = &app
		// if ! os.exists(app.path){
		// 	os.mkdir_all(app.path)?
		// }		
	}
	return f.apps[name]
}