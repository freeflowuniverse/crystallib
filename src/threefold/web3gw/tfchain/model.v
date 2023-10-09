module tfchain

[params]
pub struct Load {
pub:
	network string
	mnemonic string
}

[params]
pub struct Transfer {
pub:
	amount      u64
	destination string
}

[params]
pub struct CreateTwin {
pub:
	relay string
	pk    []byte
}

[params]
pub struct AcceptTermsAndConditions {
	link string
	hash string
}

[params]
pub struct CreateNodeContract {
	node_id              u32
	body                 string
	hash                 string
	public_ips           u32
	solution_provider_id ?u64
}

[params]
pub struct CreateRentContract {
	node_id              u32
	solution_provider_id ?u64
}

[params]
pub struct ServiceContractCreate {
	service  string
	consumer string
}

[params]
pub struct ServiceContractBill {
	contract_id     u64
	variable_amount u64
	metadata        string
}

[params]
pub struct SetServiceContractFees {
	contract_id  u64
	base_fee     u64
	variable_fee u64
}

[params]
pub struct ServiceContractSetMetadata {
	contract_id u64
	metadata    string
}

pub struct PublicIPInput {
	ip      string
	gateway string
}

[params]
pub struct CreateFarm {
	name       string
	public_ips []PublicIPInput
}

[params]
pub struct SwapToStellar {
	target_stellar_address string 
	amount u64
}

[params]
pub struct AwaitBridgedFromStellar {
pub:
	memo                            string // the memo to look for
	timeout                         int    // the timeout after which we abandon the search
	height int    // at what blockheight to start looking for the transaction
}

pub struct TwinOptionRelay {
pub: 
	has_value bool
	as_value string	
}

pub struct TwinEntityProof {
pub: 
	entity_id u32
	signature string
	
}

pub struct TwinData {
pub: 
	id u32
	account_id string
	relay TwinOptionRelay
	entities []TwinEntityProof

}

pub struct NodeResources {
pub:
	hru u64
	sru u64
	cru u64
	mru u64
}

pub struct NodeLocation {
pub:
	city string
	country string
	latitude string
	longitude string
}

pub struct NodeIP {
pub:
	ip string
	gw string
}

pub struct NodeOptionIP {
pub:
	has_value bool
	as_value NodeIP
}

pub struct NodeOptionDomain {
pub:
	has_value bool
	as_value string
}

pub struct NodePublicConfig {
pub:
	ip4 NodeIP
	ip6 NodeOptionIP
	domain NodeOptionDomain
}

pub struct NodeOptionPublicConfig {
pub:
	has_value bool
	as_value NodePublicConfig
}

pub struct NodeOptionBoardSerial {
pub:
	has_value bool
	as_value string
}

pub struct NodeCertification {
pub:
	is_diy bool
	is_certified bool
}

pub struct NodeData {
pub: 
	version u32
	id u32
	farm_id u32
	twin_id u32
	resources NodeResources
	location NodeLocation
	public_config NodeOptionPublicConfig
	created u64
	farming_policy u32
	secure_boot bool
	virtualized bool
	board_serial NodeOptionBoardSerial
	connection_price u32
}

pub struct ContractDeletedState {
pub:
	is_canceled_by_user bool
	is_out_of_funds bool
}

pub struct ContractState {
pub:
	is_created bool
	is_deleted bool
	is_grace_period bool
	as_grace_period_block_number u64
	as_deleted ContractDeletedState
}


pub struct ContractData {
pub: 
	version u32
	contract_id u64
	twin_id u32
	solution_provider_id u64
}

pub struct FarmCertification {
pub: 
	is_not_certified bool
	is_gold bool
}

pub struct FarmPublicIP {
pub: 
	ip string
	gateway string
	contract_id u64
}

pub struct FarmData {
pub: 
	version u32
	id u32
	name string
	twin_id u32
	pricing_policy_id u32
	certification_type FarmCertification
	public_ips []FarmPublicIP
	dedicated_farm bool
}