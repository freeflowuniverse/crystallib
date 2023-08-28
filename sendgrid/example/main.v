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
	
}