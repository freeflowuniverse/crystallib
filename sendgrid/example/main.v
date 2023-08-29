module main
import os
import  freeflowuniverse.crystallib.sendgrid {new_sendgrid_client}

fn main(){
	cred := sendgrid.Credintials{
			token:  os.getenv('SENDGRID_AUTH_TOKEN')
			source: os.getenv("SENDGRID_EMAIL")
			api: "https://api.sendgrid.com/v3/mail/send"
		}

	mut client := new_sendgrid_client(cred)or{ 
		println('something went wrong')
		return
	 }
	email := client.new_email([sendgrid.Personalizations{to:[sendgrid.Recipiant{email:'omarksm09@gmail.com'}]}], 'hello', [sendgrid.Content{type_: 'text/html', value:'testing'}])!
	res:= client.send(email) or { 
	print(err)
	return
		}
	println(res.str())
	
	
}