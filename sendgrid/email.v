module sendgrid
pub struct Email {
pub:
	personalizations []Personalizations [required]
	from             Recipiant          [required]
	subject          string             [required]
	content          []Content          [required]
	reply_to         ?Recipiant
	reply_to_list    ?[]Recipiant
	// TODO attatchment ?
	template_id ?string
	headers     ?map[string]string
	categories  ?[]string
	custom_args ?string
	send_at     ?i64
	batch_id    ?string
	// todo asm_ ? [json: 'asm']
	ip_pool_name ?string
	// todo mail_settings ?
	// todo tracking_settings ? 
}



pub struct Recipiant {
	email string  [required]
	name  ?string
}