module tfgrid

pub struct ZDB {
pub:
	node_id     u32
	name        string [required]
	password    string [required]
	public      bool
	size        u32    [required] // in GB
	description string
	mode        string // user, seq
}

pub struct ZDBResult {
pub:
	node_id     u32
	name        string
	password    string
	public      bool
	size        u32
	description string
	mode        string
	// computed
	namespace string
	port      u32
	ips       []string
}
