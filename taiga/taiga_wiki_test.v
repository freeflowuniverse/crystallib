module taiga

// Generate wikis with users, projects, stories, issues and tasks
fn test_generate_wiki() {
	url := 'https://staging.circles.threefold.me' // Add your taiga url
	singleton := new(url, 'admin', '123123', 100000) // Connect with username and password and cache time in seconds
	export_dir := './wiki' // set export directory
	export_all_users(export_dir, url)
	export_all_projects(export_dir, url)
	export_all_stories(export_dir, url)
	export_all_issues(export_dir, url)
	export_all_tasks(export_dir, url)
}
