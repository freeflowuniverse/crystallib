module penapp

// import os
import builder
import appsbox

const name="pen"

//just some boilerplate to get it all generic, like in other apps
[heap]
pub struct PenApp {
pub mut:
	name		string
	instance 	appsbox.AppInstance
}

pub fn get() appsbox.App{
	mut factory := appsbox.get()
	for item in factory.apps{
		if item.instance.name == name {
			return item
		}
	}
	mut i := appsbox.AppInstance{
			name:name
		}
	mut myapp := PenApp{
			name:name,
			instance:i
		}
	factory.apps << myapp
	return myapp
}

pub fn (mut myapp PenApp) install(reset bool)?{
	mut factory := appsbox.get()

	// mut n := builder.node_local()?
	myapp.instance.bins = ["pen"]

	//check app is installed, if yes don't need to do anything
	if reset || ! myapp.instance.exists(){
		myapp.build()?
	}
}

pub fn (mut myapp PenApp) start()?{

}

pub fn (mut myapp PenApp) stop()?{

}

pub fn (mut myapp PenApp) check()?bool{
	return true
}

pub fn (mut myapp PenApp) build()?{

	version := "0.34.1"

	mut factory := appsbox.get()
	mut n := builder.node_local()?
	mut cmd := $tmpl("pen_build.sh")
	n.exec(cmd:cmd, reset:true, description:"build pen ; echo ok",stdout:true, tmpdir:"/tmp/pen")?

}
