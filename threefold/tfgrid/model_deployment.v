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
	type_       string           [json: 'type'] // this is the type of the workload (ZMachine, ZDB, ...)
	data        string           [raw] // this is the workload data that contains workload specs
	metadata    string
	description string
	result      DeploymentResult
}

pub struct SignatureRequirement {
	requests        []SignatureRequest
	weight_required int
	signatures      []Signature
	signature_style string
}

pub struct SignatureRequest {
	twin_id  int
	required bool
	weight   i64
}

pub struct Signature {
	twin_id        int
	signature      string
	signature_type string
}
