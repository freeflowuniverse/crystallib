module sendgrid

pub struct Personalizations {
	to                    []Recipiant        [required]
	from                  ?Recipiant
	cc                    ?[]Recipiant
	bcc                   ?[]Recipiant
	subject               ?string
	headers               ?map[string]string
	substitutions         ?map[string]string
	dynamic_template_data ?map[string]string
	custom_args           ?map[string]string
	send_at               ?i64
}