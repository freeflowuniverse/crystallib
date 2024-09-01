module luadns

struct ARecord {
mut:
	name string
	ip   string
}

struct CNAMERecord {
mut:
	name  string
	alias string
}

struct CAARecord {
mut:
	name  string
	value string
	tag   string
}

struct DNSConfig {
mut:
	domain        string
	a_records     []ARecord
	cname_records []CNAMERecord
	caa_records   []CAARecord
}
