import despiegk.crystallib.taiga
import os

// Generate wikis with users, projects, stories, issues and tasks
fn test_generate_wiki() ? {
	env := os.environ()
	if 'TAIGA' !in env {
		println('Please export your taiga credentials in form username:password')
		exit(1)
	}
	taiga_cred := env['TAIGA'].split(':')
	mut username := ''
	mut password := ''
	if taiga_cred.len != 2 {
		println('Please export your taiga credentials in form username:password')
		exit(1)
	}
	url := 'https://staging.circles.threefold.me'
	mut t := taiga.new(url, taiga_cred[0], taiga_cred[1], 10000)
	export_dir := './wiki' // set export directory
	taiga.export(export_dir, url) ?
}
