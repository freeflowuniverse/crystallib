module pen

// import os
import despiegk.crystallib.builder
import despiegk.crystallib.appsbox

fn init() &appsbox.App{
	mut apps := appsbox.new()
	mut app := apps.get("pen")
	app.bins = ["pen"]
	return app
}

pub fn app_obj_get() ?&appsbox.App {
	app := init()
	install()?
	return app
}

fn install()?{
	
	mut app := init()

	mut n := builder.node_local()?

	app.bins = ["pen"]

	//check app is installed, if yes don't need to do anything
	if ! app.exists(){

		version := "0.34.1"
		mut bin_path := appsbox.new().bin_path

		mut cmd := $tmpl("pen_build.sh")

		n.exec(cmd:cmd, reset:true, description:"install pen ; echo ok",stdout:true, tmpdir:"/tmp/pen") or {
			return error("original cmd:\n${cmd}ERROR:\ncannot install pen\n"+err.msg()+"\n")
		}

		app.bin_register("pen")?

	}
	mut apps := appsbox.new()

}
