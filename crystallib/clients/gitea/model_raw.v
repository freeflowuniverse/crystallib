module gitea

pub struct RRepositoryInfo {
pub mut:
	full_name string
	id        int
	name      string
	owner     string
}

pub struct RRepository {
pub mut:
	allow_merge_commits               bool
	allow_rebase                      bool
	allow_rebase_explicit             bool
	allow_rebase_update               bool
	allow_squash_merge                bool
	archived                          bool
	archived_at                       string
	avatar_url                        string
	clone_url                         string
	created_at                        string
	default_allow_maintainer_edit     bool
	default_branch                    string
	default_delete_branch_after_merge bool
	default_merge_style               string
	description                       string
	empty                             bool
	// external_tracker                      RExternalTracker
	// external_wiki                         RExternalWiki
	fork                        bool
	forks_count                 int
	full_name                   string
	has_actions                 bool
	has_issues                  bool
	has_packages                bool
	has_projects                bool
	has_pull_requests           bool
	has_releases                bool
	has_wiki                    bool
	html_url                    string
	id                          int
	ignore_whitespace_conflicts bool
	internal                    bool
	// internal_tracker                      RInternalTracker
	language          string
	languages_url     string
	link              string
	mirror            bool
	mirror_interval   string
	mirror_updated    string
	name              string
	open_issues_count int
	open_pr_counter   int
	original_url      string
	owner             ROwner
	parent            string
	// permissions                           RPermissions
	private         bool
	release_counter int
	// repo_transfer                         RRepoTransfer
	size           int
	ssh_url        string
	stars_count    int
	template       bool
	updated_at     string
	url            string
	watchers_count int
	website        string
}

pub struct RExternalTracker {
pub mut:
	external_tracker_format         string
	external_tracker_regexp_pattern string
	external_tracker_style          string
	external_tracker_url            string
}

pub struct RExternalWiki {
pub mut:
	external_wiki_url string
}

pub struct RInternalTracker {
pub mut:
	allow_only_contributors_to_track_time bool
	enable_issue_dependencies             bool
	enable_time_tracker                   bool
}

pub struct ROwner {
pub mut:
	active              bool
	avatar_url          string
	created             string
	description         string
	email               string
	followers_count     int
	following_count     int
	full_name           string
	id                  int
	is_admin            bool
	language            string
	last_login          string
	location            string
	login               string
	login_name          string
	prohibit_login      bool
	restricted          bool
	starred_repos_count int
	visibility          string
	website             string
}

pub struct RPermissions {
pub mut:
	admin bool
	pull  bool
	push  bool
}

// pub struct RRepoTransfer {
// pub mut:
//     doer                                  RUser
//     recipient                             RUser
//     teams                                 []Team
// }

pub struct RUser {
pub mut:
	active              bool
	avatar_url          string
	created             string
	description         string
	email               string
	followers_count     int
	following_count     int
	full_name           string
	id                  int
	is_admin            bool
	language            string
	last_login          string
	location            string
	login               string
	login_name          string
	prohibit_login      bool
	restricted          bool
	starred_repos_count int
	visibility          string
	website             string
}

pub struct RTeam {
pub mut:
	can_create_org_repo       bool
	description               string
	id                        int
	includes_all_repositories bool
	name                      string
	organization              ROrganization
	permission                string
	units                     []string
	units_map                 map[string]string
}

pub struct ROrganization {
pub mut:
	avatar_url                    string
	description                   string
	email                         string
	full_name                     string
	id                            int
	location                      string
	name                          string
	repo_admin_change_team_access bool
	username                      string
	visibility                    string
	website                       string
}

pub struct RLabel {
pub mut:
	color       string
	description string
	exclusive   bool
	id          int
	is_archived bool
	name        string
	url         string
}

pub struct RMilestone {
pub mut:
	closed_at     string
	closed_issues int
	created_at    string
	description   string
	due_on        string
	id            int
	open_issues   int
	state         string
	title         string
	updated_at    string
}

pub struct RPullRequest {
pub mut:
	merged    bool
	merged_at string
}

pub struct RAsset {
pub mut:
	browser_download_url string
	created_at           string
	download_count       int
	id                   int
	name                 string
	size                 int
	uuid                 string
}

pub struct RIssue {
pub mut:
	assets             []RAsset
	assignee           RUser
	assignees          []RUser
	body               string
	closed_at          string
	comments           int
	created_at         string
	due_date           string
	html_url           string
	id                 int
	is_locked          bool
	labels             []RLabel
	milestone          RMilestone
	number             int
	original_author    string
	original_author_id int
	pin_order          int
	pull_request       RPullRequest
	ref                string
	repository         RRepositoryInfo
	state              string
	title              string
	updated_at         string
	url                string
	user               RUser
}
