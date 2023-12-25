module texttools

// replace '^^', '@' .
// replace '??', '$' .
// replace '\t', '    ' .
pub fn template_replace(template_ string) string {
	mut template := template_
	template = template.replace('^^', '@')
	template = template.replace('???', '$(')
	template = template.replace('??', '$')
	template = template.replace('\t', '    ')
	return template
}
