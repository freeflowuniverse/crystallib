module taiga

import os
import math { min }

// Return md file with correct empty lines
fn fix_empty_lines(md string) string {
	mut export_md := ''
	for i, line in md.split_into_lines() {
		if line.starts_with('#') || line.starts_with('>') {
			// Every header needs a new line before it and an empty file after it.
			if i == 0 {
				export_md += line + '\n\n'
			} else {
				export_md += '\n' + line + '\n\n'
			}
		} else if line == '' {
			// Ignore empty lines.
			continue
		} else {
			// Anything else will add the line as it is
			export_md += line + '\n'
		}
	}
	return export_md
}

pub fn export_all_users(export_dir string, url string) {
	os.mkdir_all("$export_dir/users") or {panic("Can't mkdir $export_dir with error: $err")}
	mut singleton := taiga.connection_get()
	mut all_users := []User{}
	for _, user in singleton.users {
		all_users << user
		user_md := user.as_md(url)
		// Export every user in a single page
		export_path := "$export_dir/users/$user.file_name"
		os.write_file(export_path, user_md) or {panic("Can't write $user.username with error: $err")}
	}
	// Export users.md page, contains a table with all users and links
	mut users_md := $tmpl('./templates/users.md')
	users_md = fix_empty_lines(users_md)
	export_path := "$export_dir/users.md"
	os.write_file(export_path, users_md) or {panic("Can't write users with error: $err")}
	println("Users Exported! ")
}

pub fn export_all_projects(export_dir string, url string){
	os.mkdir_all("$export_dir/projects") or {panic("Can't mkdir $export_dir with error: $err")}
	mut singleton := taiga.connection_get()
	mut all_projects := []Project{}
	for _, project in singleton.projects {
		all_projects << project
		proj_md := project.as_md(url)
		// Export every project in a single page
		export_path := "$export_dir/projects/$project.file_name"
		os.write_file(export_path, proj_md) or {panic("Can't write $project.name with error: $err")}
	}
	// Export projects.md page, contains a table with all users and links
	mut projects_md := $tmpl('./templates/projects.md')
	projects_md = fix_empty_lines(projects_md)
	export_path := "$export_dir/projects.md"
	os.write_file(export_path, projects_md) or {panic("Can't write projects with error: $err")}
	println("Projects Exported! ")

}

pub fn export_all_stories(export_dir string, url string){
	os.mkdir_all("$export_dir/stories") or {panic("Can't mkdir $export_dir with error: $err")}
	mut singleton := taiga.connection_get()
	mut all_stories := []Story{}
	for _, story in singleton.stories {
		all_stories << story
		story_md := story.as_md(url)
		// Export every story in a single page
		export_path := "$export_dir/stories/$story.file_name"
		os.write_file(export_path, story_md) or {panic("Can't write $story.file_name with error: $err")}
	}
	// // Export stories.md page, contains a table with all stories and links not // required
	// mut stories_md := $tmpl('./templates/stories.md')
	// stories_md = fix_empty_lines(stories_md)
	// export_path := "$export_dir/stories.md"
	// os.write_file(export_path, stories_md) or {panic("Can't write stories with error: $err")}
	// println("Projects Exported! ")
}

pub fn export_all_issues(export_dir string, url string) {

}

pub fn export_all_tasks(export_dir string, url string) {

}

pub fn export_all_epics(export_dir string, url string){

}
