module taiga

struct ProjectInfo {
pub mut:
	name      string
	slug      string
	id        int
	file_name string [skip]
}

struct UserInfo {
pub mut:
	username          string
	full_name_display string
	big_photo         string
	is_active         bool
	id                int
	public_key        string
	email             string
}

struct StatusInfo {
pub mut:
	name      string
	color     string
	is_closed bool
}

struct StoryInfo {
pub mut:
	id        int
	ref       int
	subject   string
	file_name string [skip]
}
