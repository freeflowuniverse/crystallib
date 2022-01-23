module taiga

import time { Time }

enum Category {
	blocked
	overdue
	today
	in_two_days
	in_week
	in_month
	old
	other
}

enum IssueSeverity {
	unknown
	wishlist
	minor
	normal
	important
	critical
}

enum IssuePriority {
	unknown
	low
	normal
	high
}

enum IssueStatus {
	unknown
	new
	inprogress
	verification // is called ready for test in taiga
	closed
	needsinfo
	rejected
	postponed
}

enum IssueType {
	unknown
	bug
	question
	enhancement
}

// TODO: go in circles tool, is the types not well set on the project, change them yourself !!!

pub struct Issue {
pub mut:
	description     string
	id              int
	is_private      bool
	tags            []string
	project         int // if project not found use 0
	status          IssueStatus // TODO: when decoding , be defensive, try to find what was meant in taiga
	assigned_to     []int
	owner           int
	severity        IssueSeverity // TODO: we need to create proper vlang enums, if not right set on source, use unknown
	priority        IssuePriority // TODO: we need to create proper vlang enums
	issue_type      IssueType     // TODO:
	created_date    Time
	modified_date   Time
	finished_date   Time
	due_date        Time
	due_date_reason string
	subject         string
	is_closed       bool
	is_blocked      bool
	blocked_note    string
	ref             int // TODO: is that the id of taiga, maybe we should use this on our mem db, and make it a map
	comments        []Comment
	file_name       string // need to make sure we always have ascii and namefix done
	category        Category
}

struct NewIssue {
pub mut:
	subject string
	project int
}

pub struct User {
pub mut:
	id                int
	is_active         bool
	username          string
	full_name         string
	full_name_display string
	bio               string
	photo             string
	roles             []string // TODO: SHOULD BE ENUM , don't understand where this comes from, seems odd to me
	email             string
	public_key        string
	date_joined       Time
	file_name         string
}

enum TaskStatus {
	// TODO: there will be many other statuses used, we have to fix, in taiga itself, make the story status as below eveywhere
	unknown
	new
	accepted
	inprogress
	verification // is called ready for test in taiga
	done
}

pub struct Task {
pub mut:
	description     string
	id              int
	tags            []string
	project         int
	user_story      int
	status          TaskStatus
	assigned_to     []int
	owner           int
	created_date    Time
	modified_date   Time
	finished_date   Time
	due_date        Time
	due_date_reason string
	subject         string
	is_closed       bool
	is_blocked      bool
	blocked_note    string
	ref             int
	comments        []Comment
	file_name       string
	category        Category
}

enum StoryStatus {
	// TODO: there will be many other statuses used, we have to fix, in taiga itself, make the story status as below eveywhere
	unknown
	new
	accepted
	inprogress
	verification // is called ready for test in taiga
	done
}

pub struct Story {
pub mut:
	description     string
	id              int
	is_private      bool
	tags            []string
	project         int
	status          StoryStatus // TODO: use an enumerator
	assigned_to     []int
	owner           int
	created_date    Time
	modified_date   Time
	finish_date     Time
	due_date        Time
	due_date_reason string
	subject         string
	is_closed       bool
	is_blocked      bool
	blocked_note    string
	ref             int
	comments        []Comment
	file_name       string
	category        Category
}

struct NewStory {
pub mut:
	subject string
	project int
}

enum MemberRole {
	unknown
	coordinator
	stakeholder
	member
	contributor
	follower
	admin
}

pub struct Member {
pub mut:
	user int        // link to the user on memdb
	role MemberRole // TODO: check, if not well configured, go into the project (circle), and change the names so it does reflect
}

type TaigaElement = Epic | Issue | Story | Task

struct NewProject {
pub mut:
	name                 string
	description          string
	is_issues_activated  bool
	is_private           bool
	is_backlog_activated bool
	is_kanban_activated  bool
	is_wiki_activated    bool
}

struct NewProjectConfig {
pub mut:
	severities      []string
	priorities      []string
	issues_types    []string
	issues_statuses []string
	story_statuses  []string
	task_statuses   []string
	item_statuses   []string
	custom_fields   []string
}

pub enum ProjectType {
	unknown
	funnel
	project
	team
	coordination
}

pub struct Project {
pub mut:
	created_date  Time
	modified_date Time
	name          string
	description   string
	id            int
	is_private    bool
	// members       []Member
	members   []int // for now will change that later
	tags      []string
	slug      string
	owner     int
	projtype  ProjectType
	file_name string
}

struct Comment {
pub mut:
	id                  string
	comment             string
	user_id             int // should just refer to the id of the user who did the comment
	created_at          Time
	key                 string
	comment_html        string
	delete_comment_date Time
	delete_comment_user string
	edit_comment_date   Time
	is_hidden           bool
}

pub struct Epic {
pub mut:
	description     string
	id              int
	is_private      bool
	tags            []string
	project         int
	user_story      int
	status          int
	assigned_to     int
	owner           int
	created_date    Time
	modified_date   Time
	finished_date   Time
	due_date        Time
	due_date_reason string
	subject         string
	is_closed       bool
	is_blocked      bool
	ref             int
	file_name       string
	category        Category
}

struct NewEpic {
pub mut:
	subject string
	project int
}
