module mdbookapp

// import os
import builder
import appsbox

const name="mdbook"

//just some boilerplate to get it all generic, like in other apps
[heap]
pub struct MDBookApp {
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
	mut myapp := MDBookApp{
			name:name,
			instance:i
		}
	factory.apps << myapp
	return myapp
}

pub fn (mut myapp MDBookApp) install(reset bool)?{
	mut factory := appsbox.get()

	//TODO, needs to check if rust installed and if not do so, need appsbox for rust

	// mut n := builder.node_local()?
	myapp.instance.bins = ["mdbook"]

	//check app is installed, if yes don't need to do anything
	if reset || ! myapp.instance.exists(){
		myapp.build()?
	}
}

pub fn (mut myapp MDBookApp) start()?{

}

pub fn (mut myapp MDBookApp) stop()?{

}

pub fn (mut myapp MDBookApp) check()?bool{
	return true
}

pub fn (mut myapp MDBookApp) build()?{

	// version := "0.34.1"

	mut factory := appsbox.get()
	mut n := builder.node_local()?
	mut cmd := $tmpl("build.sh")
	n.exec(cmd:cmd, reset:true, description:"build mdbook ; echo ok",stdout:true, tmpdir:"/tmp/mdbook")?

}
