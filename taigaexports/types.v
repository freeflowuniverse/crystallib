module taigaexports

// AttachedFile
pub struct AttachedFile {
pub mut:
	data string
	name string
}

// Attachment
pub struct Attachment {
pub mut:
	attached_file  string
	description    string
	filename       string
	id             int
	is_deprecated  bool
	order          int
	thumbnail_file string
	url            string
}

// Attachments
pub struct Attachments {
pub mut:
	changed []Attachment
	deleted []Attachment
	new     []Attachment
}

// StoryAttachment
pub struct StoryAttachment {
pub mut:
	attached_file AttachedFile
	created_date  string
	description   string
	is_deprecated bool
	modified_date string
	name          string
	order         int
	owner         string
	sha1          string
	size          int
}

// CommentVersion
pub struct CommentVersion {
pub mut:
	comment      string
	comment_html string
	date         string
	user         CommentVersionUser
}

// CommentVersionUser
pub struct CommentVersionUser {
pub mut:
	id int
}

// CustomAttributesValues
pub struct CustomAttributesValues {
}

// Data
pub struct TimelineData {
pub mut:
	comment          string
	comment_edited   bool
	comment_html     string
	epic             TimelineDataItem
	issue            TimelineDataItem
	project          Project
	relateduserstory Relateduserstory
	role             DataRole
	task             TimelineDataItem
	user             DataUser
	userstory        TimelineDataItem
	values_diff      ValuesDiff
}

// DataRole
pub struct DataRole {
pub mut:
	id   int
	name string
}

// DataUser
pub struct DataUser {
pub mut:
	email string
}

// Duedate
pub struct Duedate {
pub mut:
	by_default  bool
	color       string
	days_to_due int
	name        string
	order       int
}

// EpicElement
pub struct EpicElement {
pub mut:
	assigned_to              string
	attachments              []Attachment
	blocked_note             string
	client_requirement       bool
	color                    string
	created_date             string
	custom_attributes_values CustomAttributesValues
	description              string
	epics_order              int
	history                  []EpicHistory
	is_blocked               bool
	modified_date            string
	owner                    string
	ref                      int
	related_user_stories     []RelatedUserStory
	status                   string
	subject                  string
	tags                     []string
	team_requirement         bool
	version                  int
	watchers                 []string
}

// EpicHistory
pub struct EpicHistory {
pub mut:
	comment             string
	comment_versions    []CommentVersion
	created_at          string
	delete_comment_date string
	delete_comment_user []string
	diff                CustomAttributesValues
	edit_comment_date   string
	is_hidden           bool
	is_snapshot         bool
	snapshot            EpicHistorySnapshot
	type_               int                    [json: 'type']
	user                []string
	values              CommonValues
}

// UserStoryHistoryDiff
pub struct UserStoryHistoryDiff {
pub mut:
	attachments []Attachment
}

// TaskHistorySnapshot
pub struct TaskHistorySnapshot {
pub mut:
	assigned_to       string
	attachments       []Attachment
	blocked_note      string
	blocked_note_html string
	custom_attributes []string
	description       string
	description_html  string
	due_date          string
	is_blocked        bool
	is_iocaine        bool
	milestone         string
	owner             string
	priority          int
	ref               int
	severity          int
	status            string
	subject           string
	tags              []string
	taskboard_order   int
	type_             int          [json: 'type']
	us_order          int
	user_story        UserStory
}

// IssueHistoryValues
pub struct IssueHistoryValues {
pub mut:
	priority map[string]string
	users    []string
}

// Issue
pub struct Issue {
pub mut:
	assigned_to              string
	attachments              []Attachment
	blocked_note             string
	created_date             string
	custom_attributes_values CustomAttributesValues
	description              string
	due_date                 string
	due_date_reason          string
	external_reference       string
	finished_date            string
	history                  []IssueHistory
	is_blocked               bool
	milestone                string
	modified_date            string
	owner                    string
	priority                 string
	ref                      int
	severity                 string
	status                   string
	subject                  string
	tags                     []string
	type_                    string                 [json: 'type']
	version                  int
	votes                    []string
	watchers                 []string
}

pub struct InnerTimelineDataItem {
pub mut:
	id      int
	project Project
	ref     int
	subject string
}

// TimelineDataItem
pub struct TimelineDataItem {
pub mut:
	id        int
	project   Project
	ref       int
	subject   string
	userstory InnerTimelineDataItem
}

// Snapshot
pub struct Snapshot {
pub mut:
	ref               int
	tags              []string
	type_             int          [json: 'type']
	owner             string
	status            string
	subject           string
	due_date          string
	priority          int
	severity          int
	milestone         string
	is_blocked        bool
	assigned_to       string
	attachments       []Attachment
	description       string
	blocked_note      string
	description_html  string
	blocked_note_html string
	custom_attributes []string
}

// IssueHistory
pub struct IssueHistory {
pub mut:
	comment             string
	comment_versions    []CommentVersion
	created_at          string
	delete_comment_date string
	delete_comment_user []string
	diff                IssueHistoryDiff
	edit_comment_date   string
	is_hidden           bool
	is_snapshot         bool
	snapshot            Snapshot
	type_               int              [json: 'type']
	user                []string
	// values IssueHistoryValues
}

// IssueType
pub struct IssueType {
pub mut:
	color string
	name  string
	order int
}

// Membership
pub struct Membership {
pub mut:
	created_at            string
	email                 string
	invitation_extra_text string
	invited_by            string
	is_admin              bool
	role                  string
	user                  string
	user_order            int
}

// Point
pub struct Point {
pub mut:
	name  string
	order int
	value f64
}

// Project
pub struct Project {
pub mut:
	description string
	id          int
	name        string
	slug        string
}

// IssueHistoryDiff
pub struct IssueHistoryDiff {
pub mut:
	blocked_note      []string
	blocked_note_html []string
	due_date          []string
	is_blocked        []bool
	priority          []int
}

// EpicHistorySnapshot
pub struct EpicHistorySnapshot {
pub mut:
	assigned_to        string
	attachments        []Attachment
	blocked_note       string
	blocked_note_html  string
	client_requirement bool
	color              string
	custom_attributes  []string
	description        string
	description_html   string
	epics_order        int
	is_blocked         bool
	owner              string
	ref                int
	status             string
	subject            string
	tags               []string
	team_requirement   bool
}

// CommonValues
pub struct CommonValues {
pub mut:
	users []string
}

// RelatedUserStory
pub struct RelatedUserStory {
pub mut:
	order      int
	user_story int
}

// Relateduserstory
pub struct Relateduserstory {
pub mut:
	id      int
	subject string
}

// RoleElement
pub struct RoleElement {
pub mut:
	computable  bool
	name        string
	order       int
	permissions []string
	slug        string
}

// RolePoint
pub struct RolePoint {
pub mut:
	points string
	role   string
}

// Status
pub struct Status {
pub mut:
	color     string
	is_closed bool
	name      string
	order     int
	slug      string
}

// Task
pub struct Task {
pub mut:
	assigned_to              string
	attachments              []Attachment
	blocked_note             string
	created_date             string
	custom_attributes_values CustomAttributesValues
	description              string
	due_date                 string
	due_date_reason          string
	external_reference       string
	finished_date            string
	history                  []TaskHistory
	is_blocked               bool
	is_iocaine               bool
	milestone                string
	modified_date            string
	owner                    string
	ref                      int
	status                   string
	subject                  string
	tags                     []string
	taskboard_order          int
	us_order                 int
	user_story               UserStory
	version                  int
	watchers                 []string
}

// TaskHistory
pub struct TaskHistory {
pub mut:
	comment             string
	comment_versions    []CommentVersion
	created_at          string
	delete_comment_date string
	delete_comment_user []string
	diff                CustomAttributesValues
	edit_comment_date   string
	is_hidden           bool
	is_snapshot         bool
	snapshot            TaskHistorySnapshot
	type_               int                    [json: 'type']
	user                []string
	values              CommonValues
}

// UserStoryHistorySnapshot
pub struct UserStoryHistorySnapshot {
pub mut:
	assigned_to        string
	assigned_users     []int
	attachments        []Attachment
	backlog_order      int
	blocked_note       string
	blocked_note_html  string
	client_requirement bool
	custom_attributes  []string
	description        string
	description_html   string
	due_date           string
	finish_date        string
	from_issue         string
	from_task          string
	is_blocked         bool
	is_closed          bool
	kanban_order       int
	milestone          string
	owner              string
	// failed in decoding despite there's correct value
	// despite it can decode outer map types
	// maybe because it's an inner value here?
	// points map[string]int
	ref              int
	sprint_order     int
	status           string
	subject          string
	tags             []string
	team_requirement bool
	tribe_gig        string
}

// Timeline
pub struct Timeline {
pub mut:
	created             string
	data                TimelineData
	data_content_struct []string
	event_struct        string
}

// UsStatus
pub struct UsStatus {
pub mut:
	color       string
	is_archived bool
	is_closed   bool
	name        string
	order       int
	slug        string
	wip_limit   string
}

// UserStory
pub struct UserStory {
pub mut:
	assigned_to              string
	assigned_users           []string
	attachments              []StoryAttachment
	backlog_order            int
	blocked_note             string
	client_requirement       bool
	created_date             string
	custom_attributes_values CustomAttributesValues
	description              string
	due_date                 string
	due_date_reason          string
	external_reference       string
	finish_date              string
	generated_from_issue     string
	generated_from_task      string
	history                  []UserStoryHistory
	is_blocked               bool
	is_closed                bool
	kanban_order             int
	milestone                string
	modified_date            string
	owner                    string
	ref                      int
	role_points              []RolePoint
	sprint_order             int
	status                   string
	subject                  string
	tags                     []string
	team_requirement         bool
	tribe_gig                string
	version                  int
	watchers                 []string
}

// UserStoryHistory
pub struct UserStoryHistory {
pub mut:
	comment             string
	comment_versions    []CommentVersion
	created_at          string
	delete_comment_date string
	delete_comment_user []string
	diff                UserStoryHistoryDiff
	edit_comment_date   string
	is_hidden           bool
	is_snapshot         bool
	snapshot            UserStoryHistorySnapshot
	type_               int                      [json: 'type']
	user                []string
	values              CommonValues
}

// ValuesDiff
pub struct ValuesDiff {
pub mut:
	anon_permissions     [][]string
	attachments          Attachments
	blocked_note_diff    []string
	blocked_note_html    []string
	due_date             []string
	is_backlog_activated []bool
	is_blocked           []bool
	is_epics_activated   []bool
	is_issues_activated  []bool
	priority             []string
	public_permissions   [][]string
}

pub struct ProjectExport {
pub mut:
	anon_permissions            []string
	blocked_code                string
	created_date                string
	creation_template           string
	default_epic_status         string
	default_issue_status        string
	default_issue_struct        string
	default_points              string
	default_priority            string
	default_severity            string
	default_task_status         string
	default_us_status           string
	description                 string
	epic_statuses               []Status
	epiccustomattributes        []string
	epics                       []EpicElement
	epics_csv_uuid              string
	is_backlog_activated        bool
	is_epics_activated          bool
	is_featured                 bool
	is_issues_activated         bool
	is_kanban_activated         bool
	is_looking_for_people       bool
	is_private                  bool
	is_wiki_activated           bool
	issue_duedates              []Duedate
	issue_statuses              []Status
	issue_types                 []IssueType
	issuecustomattributes       []string
	issues                      []Issue
	issues_csv_uuid             string
	logo                        string
	looking_for_people_note     string
	memberships                 []Membership
	milestones                  []string
	modified_date               string
	name                        string
	owner                       string
	points                      []Point
	priorities                  []IssueType
	public_permissions          []string
	roles                       []RoleElement
	severities                  []IssueType
	slug                        string
	tags                        []string
	tags_colors                 []string
	task_duedates               []Duedate
	task_statuses               []Status
	taskcustomattributes        []string
	tasks                       []Task
	tasks_csv_uuid              string
	timeline                    []Timeline
	total_activity              int
	total_activity_last_month   int
	total_activity_last_week    int
	total_activity_last_year    int
	total_fans                  int
	total_fans_last_month       int
	total_fans_last_week        int
	total_fans_last_year        int
	total_milestones            string
	total_story_points          string
	totals_updated_datetime     string
	transfer_token              string
	us_duedates                 []Duedate
	us_statuses                 []UsStatus
	user_stories                []UserStory
	userstories_csv_uuid        string
	userstorycustomattributes   []string
	videoconferences            string
	videoconferences_extra_data string
	watchers                    []string
	wiki_links                  []string
	wiki_pages                  []string
}
