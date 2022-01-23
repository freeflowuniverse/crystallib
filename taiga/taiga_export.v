module taiga
import despiegk.crystallib.crystaljson
import despiegk.crystallib.texttools
import os
import math

const README='
# Export for Taiga

...

'

const SIDEBAR='
[Home](readme)
[Users](users)
[Projects](projects)
'

pub fn export(export_dir string, url string) ? {
	if os.exists(export_dir){
		os.rmdir_all(export_dir)?
	}
	export_all_users(export_dir, url) ?
	export_all_projects(export_dir, url) ?
	export_all_stories(export_dir, url) ?
	export_all_issues(export_dir, url) ?
	export_all_tasks(export_dir, url) ?
	os.write_file('$export_dir/readme.md', README) ?
	os.write_file('$export_dir/sidebar.md', SIDEBAR) ?
}

pub fn export_all_users(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/users') or {
		return error("Can't mkdir $export_dir with error: $err")
	}
	mut singleton := connection_get()
	mut all_users := []User{}
	for _, user in singleton.users {
		all_users << user
		user_md := user.as_md(url)
		// Export every user in a single page
		export_path := '$export_dir/users/${user.file_name}'
		os.write_file(export_path, user_md) or {
			return error("Can't write $user.username with error: $err")
		}
	}
	// Export users.md page, contains a table with all users and links
	mut users_md := $tmpl('./templates/users.md')
	users_md = fix_empty_lines(users_md)
	export_path := '$export_dir/users.md'
	os.write_file(export_path, users_md) or { return error("Can't write users with error: $err") }
	println('Users Exported!')
}

pub fn export_all_projects(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/projects') or { panic("Can't mkdir $export_dir with error: $err") }
	mut singleton := connection_get()
	mut all_projects := []Project{}
	for _, project in singleton.projects {
		all_projects << project
		proj_md := project.as_md(url)
		// Export every project in a single page
		export_path := '$export_dir/projects/${project.file_name}'
		os.write_file(export_path, proj_md) or {
			panic("Can't write $project.name with error: $err")
		}
	}
	// Export projects.md page, contains a table with all users and links
	mut projects_md := $tmpl('./templates/projects.md')
	projects_md = fix_empty_lines(projects_md)
	export_path := '$export_dir/projects.md'
	os.write_file(export_path, projects_md) or { panic("Can't write projects with error: $err") }
	println('Projects Exported!')
}

pub fn export_all_stories(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/stories') or { panic("Can't mkdir $export_dir with error: $err") }
	mut singleton := connection_get()
	mut all_stories := []Story{}
	for _, story in singleton.stories {
		all_stories << story
		story_md := story.as_md(url)
		// Export every story in a single page
		export_path := '$export_dir/stories/${story.file_name}'
		os.write_file(export_path, story_md) or {
			panic("Can't write $story.file_name with error: $err")
		}
	}
	// // Export stories.md page, contains a table with all stories and links not // required
	// mut stories_md := $tmpl('./templates/stories.md')
	// stories_md = fix_empty_lines(stories_md)
	// export_path := "$export_dir/stories.md"
	// os.write_file(export_path, stories_md) or {panic("Can't write stories with error: $err")}
	println('Stories Exported!')
}

pub fn export_all_issues(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/issues') or { panic("Can't mkdir $export_dir with error: $err") }
	mut singleton := connection_get()
	mut all_issues := []Issue{}
	for _, issue in singleton.issues {
		all_issues << issue
		issue_md := issue.as_md(url)
		// Export every issue in a single page
		export_path := '$export_dir/issues/${issue.file_name}'
		os.write_file(export_path, issue_md) or {
			panic("Can't write $issue.file_name with error: $err")
		}
	}
	// // Export issues.md page, contains a table with all issues and links // not required
	// mut issues_md := $tmpl('./templates/issues.md')
	// issues_md = fix_empty_lines(issues_md)
	// export_path := "$export_dir/issues.md"
	// os.write_file(export_path, issues_md) or {panic("Can't write issues with error: $err")}
	println('Issues Exported!')
}

pub fn export_all_tasks(export_dir string, url string) ? {
	os.mkdir_all('$export_dir/tasks') or { panic("Can't mkdir $export_dir with error: $err") }
	mut singleton := connection_get()
	// mut all_tasks := []Task{}
	for _, task in singleton.tasks {
		// all_tasks << task
		task_md := task.as_md(url)
		// Export every task in a single page
		export_path := '$export_dir/tasks/${task.file_name}'
		os.write_file(export_path, task_md) or {
			panic("Can't write $task.file_name with error: $err")
		}
	}
	// // Export tasks.md page, contains a table with all tasks and links // not required
	// mut tasks_md := $tmpl('./templates/tasks.md')
	// tasks_md = fix_empty_lines(tasks_md)
	// export_path := "$export_dir/tasks.md"
	// os.write_file(export_path, tasks_md) or {panic("Can't write tasks with error: $err")}
	println('Tasks Exported!')
}

