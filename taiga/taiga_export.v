module taiga

import os

const read_me = '
# Export for Taiga

...

'

const side_bar = '
[Home](readme)
[Users](users)
[Projects](projects)
'

pub fn export(export_dir string, url string) ? {
	if os.exists(export_dir) {
		os.rmdir_all(export_dir)?
	}
	export_all_users(export_dir, url)?
	export_all_projects(export_dir, url)?
	export_all_stories(export_dir, url)?
	export_all_issues(export_dir, url)?
	export_all_tasks(export_dir, url)?
	os.write_file('$export_dir/readme.md', taiga.read_me)?
	os.write_file('$export_dir/sidebar.md', taiga.side_bar)?
}

pub fn export_all_users(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/users')?
	mut singleton := connection_get()
	mut all_users := []User{}
	for _, user in singleton.users {
		all_users << user
		user_md := user.as_md(url)
		// Export every user in a single page
		export_path := '$export_dir/users/$user.file_name'
		os.write_file(export_path, user_md)?
	}
	// Export users.md page, contains a table with all users and links
	mut users_md := $tmpl('./templates/users.md')
	users_md = fix_empty_lines(users_md)
	export_path := '$export_dir/users.md'
	os.write_file(export_path, users_md)?
	println('Users Exported!')
}

pub fn export_all_projects(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/projects')?
	mut singleton := connection_get()
	mut all_projects := []Project{}
	for _, project in singleton.projects {
		all_projects << project
		proj_md := project.as_md(url)
		// Export every project in a single page
		export_path := '$export_dir/projects/$project.file_name'
		os.write_file(export_path, proj_md)?
	}
	// Export projects.md page, contains a table with all users and links
	mut projects_md := $tmpl('./templates/projects.md')
	projects_md = fix_empty_lines(projects_md)
	export_path := '$export_dir/projects.md'
	os.write_file(export_path, projects_md)?
	println('Projects Exported!')
}

pub fn export_all_stories(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/stories')?
	mut singleton := connection_get()
	for _, story in singleton.stories {
		story_md := story.as_md(url)
		export_path := '$export_dir/stories/$story.file_name'
		os.write_file(export_path, story_md)?
	}
	println('Stories Exported!')
}

pub fn export_all_issues(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/issues')?
	mut singleton := connection_get()
	for _, issue in singleton.issues {
		issue_md := issue.as_md(url)
		export_path := '$export_dir/issues/$issue.file_name'
		os.write_file(export_path, issue_md)?
	}
	println('Issues Exported!')
}

pub fn export_all_tasks(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/tasks')?
	mut singleton := connection_get()
	for _, task in singleton.tasks {
		task_md := task.as_md(url)
		export_path := '$export_dir/tasks/$task.file_name'
		os.write_file(export_path, task_md)?
	}
	println('Tasks Exported!')
}
