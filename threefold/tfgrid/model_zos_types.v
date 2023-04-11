module tfgrid

pub struct ZOSNodeRequest {
pub:
	node_id u32    [json: 'node_id']
	data    string [json: 'data']
}

pub struct Deployment {
pub:
	version               u32                  [json: 'version']
	twin_id               u32                  [json: 'twin_id']
	contract_id           u64                  [json: 'contract_id']
	metadata              string               [json: 'metadata']
	description           string               [json: 'description']
	expiration            i64                  [json: 'expiration']
	signature_requirement SignatureRequirement [json: 'signature_requirement']
	workloads             []Workload           [json: 'workloads']
}

pub struct SignatureRequirement {
pub:
	requests        []SignatureRequest [json: 'requests']
	weight_required u32                [json: 'weight_required']
	signatures      []Signature        [json: 'signatures']
	signature_style string             [json: 'signature_style']
}

pub struct SignatureRequest {
pub:
	twin_id  u32  [json: 'twin_id']
	required bool [json: 'required']
	weight   u32  [json: 'weight']
}

pub struct Signature {
pub:
	twin_id        u32    [json: 'twin_id']
	signature      string [json: 'signature']
	signature_type string [json: 'signature_type']
}

pub struct Workload {
pub:
	version       u32    [json: 'version']
	name          string [json: 'name']
	workload_type string [json: 'type']
	data          string [json: 'data'; raw]
	metadata      string [json: 'metadata']
	description   string [json: 'description']
	result        Result [json: 'result']
}

pub struct Result {
pub:
	created i64    [json: 'created']
	state   string [json: 'state']
	error   string [json: 'error']
	data    string [json: 'data'; raw]
}

pub struct SystemVersion {
pub:
	zos   string [json: 'zos']
	zinit string [json: 'zinit']
}

pub struct DMI {
pub:
	tooling  Tooling   [json: 'tooling']
	sections []Section [json: 'sections']
}

struct Tooling {
	aggregator string [json: 'aggregator']
	decoder    string [json: 'decoder']
}

struct Section {
	handleline  string       [json: 'handleline']
	typestr     string       [json: 'typestr']
	type_       int          [json: 'typenum']
	subsections []Subsection [json: 'subsections']
}

struct Subsection {
	title      string                  [json: 'title']
	properties map[string]PropertyData [json: 'properties']
}

struct PropertyData {
	value string   [json: 'value']
	items []string [json: 'items']
}

pub struct PublicConfig {
pub:
	type_  string [json: 'type']
	ipv4   string [json: 'ipv4']
	ipv6   string [json: 'ipv6']
	gw4    string [json: 'gw4']
	gw6    string [json: 'gw6']
	domain string [json: 'domain']
}

pub struct Statistics {
pub:
	total Capacity [json: 'total']
	used  Capacity [json: 'used']
}

struct Capacity {
	cru   u64 [json: 'cru']
	hru   u64 [json: 'hru']
	sru   u64 [json: 'sru']
	mru   u64 [json: 'mru']
	ipv4u u64 [json: 'ipv4u']
}
