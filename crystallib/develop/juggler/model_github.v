module juggler

import json

struct RepositoryOwner {
	name              string
	email             string
	login             string
	id                int
	node_id           string
	avatar_url        string
	gravatar_id       string
	url               string
	html_url          string
	followers_url     string
	following_url     string
	gists_url         string
	starred_url       string
	subscriptions_url string
	organizations_url string
	repos_url         string
	events_url        string
	received_events_url string
	type_              string @[json: 'type']
	site_admin        bool
}

struct License {
	key     string
	name    string
	spdx_id string
	url     string
	node_id string
}

struct GithubRepository {
	id                int
	node_id           string
	name              string
	full_name         string
	private           bool
	owner             RepositoryOwner
	html_url          string
	description       string
	fork              bool
	url               string
	forks_url         string
	keys_url          string
	collaborators_url string
	teams_url         string
	hooks_url         string
	issue_events_url  string
	events_url        string
	assignees_url     string
	branches_url      string
	tags_url          string
	blobs_url         string
	git_tags_url      string
	git_refs_url      string
	trees_url         string
	statuses_url      string
	languages_url     string
	stargazers_url    string
	contributors_url  string
	subscribers_url   string
	subscription_url  string
	commits_url       string
	git_commits_url   string
	comments_url      string
	issue_comment_url string
	contents_url      string
	compare_url       string
	merges_url        string
	archive_url       string
	downloads_url     string
	issues_url        string
	pulls_url         string
	milestones_url    string
	notifications_url string
	labels_url        string
	releases_url      string
	deployments_url   string
	created_at        int
	updated_at        string
	pushed_at         int
	git_url           string
	ssh_url           string
	clone_url         string
	svn_url           string
	homepage          string
	size              int
	stargazers_count  int
	watchers_count    int
	language          string
	has_issues        bool
	has_projects      bool
	has_downloads     bool
	has_wiki          bool
	has_pages         bool
	has_discussions   bool
	forks_count       int
	mirror_url        string
	archived          bool
	disabled          bool
	open_issues_count int
	license           License
	allow_forking     bool
	is_template       bool
	web_commit_signoff_required bool
	topics            []string
	visibility        string
	forks             int
	open_issues       int
	watchers          int
	default_branch    string
	stargazers        int
	master_branch     string
	organization      string
	custom_properties map[string]string
}

struct Pusher {
	name  string
	email string
}

struct Organization {
	login              string
	id                 int
	node_id            string
	url                string
	repos_url          string
	events_url         string
	hooks_url          string
	issues_url         string
	members_url        string
	public_members_url string
	avatar_url         string
	description        string
}

struct Sender {
	login              string
	id                 int
	node_id            string
	avatar_url         string
	gravatar_id        string
	url                string
	html_url           string
	followers_url      string
	following_url      string
	gists_url          string
	starred_url        string
	subscriptions_url  string
	organizations_url  string
	repos_url          string
	events_url         string
	received_events_url string
	type_               string @[json: 'type']
	site_admin         bool
}

struct AuthorCommitter {
	name     string
	email    string
	username string
}

struct GithubCommit {
	id        string
	tree_id   string
	distinct  bool
	message   string
	timestamp string
	url       string
	author    AuthorCommitter
	committer AuthorCommitter
	added     []string
	removed   []string
	modified  []string
}

struct HeadCommit {
	id        string
	tree_id   string
	distinct  bool
	message   string
	timestamp string
	url       string
	author    AuthorCommitter
	committer AuthorCommitter
	added     []string
	removed   []string
	modified  []string
}

struct GitHubPayload {
	ref          string
	before       string
	after        string
	repository   GithubRepository
	pusher       Pusher
	organization Organization
	sender       Sender
	created      bool
	deleted      bool
	forced       bool
	base_ref     string
	compare      string
	commits      []GithubCommit
	head_commit  HeadCommit
}