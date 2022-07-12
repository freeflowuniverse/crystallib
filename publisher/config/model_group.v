module config

pub struct UserGroup {
pub mut:
	name           string // needs to be unique
	members_users  []string
	members_groups []string
}
