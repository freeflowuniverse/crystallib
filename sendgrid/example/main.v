module main

import os
import freeflowuniverse.crystallib.sendgrid { new_client }

fn main() {
	
		token:= os.getenv('SENDGRID_AUTH_TOKEN')
	

	mut client := new_client(token) or {
		println('something went wrong')
		return
	}

	email := sendgrid.new_email(['mariobassem12@gmail.com', 'omarksm09@gmail.com'], "omarkassem099@gmail.com",
		'finally works', 'done today')
	res := client.send(email) or {
		print(err)
		return
	}
	println(res.str())
}
