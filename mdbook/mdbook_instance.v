module mdbook

// import builder
import os


[heap]
struct MDBookInstance {
mut:
	name string
	
}


fn (mut f MDBookFactory) new (name string) ?&MDBookInstance{
	mut i := MDBookInstance{name:name}
	f.instances[name] = &i
	return &i
}

fn (mut f MDBookFactory) get (name string) ?&MDBookInstance{
	if ! (name in f.instances){
		return error("cannot find mdbook instance with name $name")
	}

	return f.instances[name]

}


//sign a piece of content, return signature
fn (f MDBookInstance) process_page (content string) ?{
}
