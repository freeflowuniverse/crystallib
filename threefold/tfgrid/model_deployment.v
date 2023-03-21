module tfgrid

pub struct Deployment {
pub mut:
	version               int
	twin_id               u32
	contract_id           u64
	expiration            i64
	metadata              string
	description           string
	workloads             []Workload
	signature_requirement SignatureRequirement
}

pub struct ResultStates {
pub:
	error   string = 'error'
	ok      string = 'ok'
	deleted string = 'deleted'
}

pub struct DeploymentResult {
pub mut:
	created i64
	state   string
	error   string
	data    string [raw]
}

pub struct Workload {
pub mut:
	version     int
	name        string
	type_       string           [json: 'type'] // TODO: what is this?
	data        string           [raw] // TODO: what is this?
	metadata    string
	description string
	result      DeploymentResult
}
