module juggler

import time

pub struct Repository {
pub mut:
	id     u32
	owner  string @[required]
	name   string @[required]
	host   string @[required]
	branch string @[required]
}

pub struct Commit {
pub:
	committer string
	message   string
	time      time.Time
	hash      string
	url       string
}

pub fn (r Repository) identifier() string {
	return '${r.owner}_${r.name}_${r.branch}'
}

pub fn (r Repository) path() string {
	host := if r.host == 'github.com' {
		'github'
	} else {
		r.host
	}
	return '${host}/${r.owner}/${r.name}/${r.branch}'
}

pub fn (r Repository) full_name() string {
	return '${r.owner}/${r.name}'
}
