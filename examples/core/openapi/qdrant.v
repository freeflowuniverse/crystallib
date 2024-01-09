module main

import os

const spec_path = '${os.dir(@FILE)}/openapi.json'

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	spec := openapi.load(spec_path)!
	for name, path in spec.paths{
		if post := path.post {
			if request_body := post.request_body{
				println("${name}:>>> ${request_body}")
			}else{
				println(name)
			}
	}
	
}
}
