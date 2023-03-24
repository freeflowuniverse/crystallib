module tfgrid

pub struct DeployResponse {
pub:
	contracts        ContractResponse
	wireguard_config string
}

pub struct ContractResponse {
pub:
	created []Contract
	updated []Contract
	deleted []SimpleDeleteContract
}

// TODO: what is this, doesn't seem to make sense, what is the string
// TODO: shouldn't this be an enumerator
struct ContractState {
pub:
	created string
	deleted string
}

// TODO: same here contract_type!! what is it
pub struct Contract {
pub:
	version       u32
	contract_id   u64           [json: 'contractId']
	twin_id       u32           [json: 'twinId']
	contract_type ContractTypes [json: 'contractType'] // TODO, what is this, what do we try to do
	state         ContractState
}
