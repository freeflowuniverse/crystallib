module twinclient2

[params]
pub struct SingleDelete {
pub:
	name            string [required]
	deployment_name string [required]
}

pub struct Disk {
pub:
	name       string [required]
	size       u32    [required]
	mountpoint string [required]
}

[params]
pub struct QsfsDisk {
pub:
	qsfs_zdbs_name  string [required]
	name            string [required]
	prefix          string [required]
	encryption_key  string [required]
	cache           u32
	minimal_shards  u32
	expected_shards u32
	mountpoint      string [required]
}

pub struct Network {
pub:
	ip_range   string [required]
	name       string [required]
	add_access bool   [json: 'addAccess']
}

pub struct Machine {
pub:
	name        string     [required]
	node_id     u32        [required]
	disks       []Disk
	qsfs_disks  []QsfsDisk
	public_ip   bool       [required]
	planetary   bool       [required]
	cpu         u32        [required]
	memory      u64        [required]
	rootfs_size u64        [required]
	flist       string     [required]
	entrypoint  string     [required]
	env         Env
}

[params]
pub struct AddMachine {
pub:
	deployment_name string     [required]
	name            string     [required]
	node_id         u32        [required]
	disks           []Disk
	qsfs_disks      []QsfsDisk
	public_ip       bool       [required]
	planetary       bool       [required]
	cpu             u32        [required]
	memory          u64        [required]
	rootfs_size     u64        [required]
	flist           string     [required]
	entrypoint      string     [required]
	env             Env
}

[params]
pub struct Machines {
pub:
	name        string    [required]
	network     Network   [required]
	machines    []Machine [required]
	metadata    string
	description string
}

pub struct KubernetesNode {
pub:
	name        string     [required]
	node_id     u32        [required]
	cpu         u32        [required]
	memory      u64        [required]
	rootfs_size u32        [required]
	disk_size   u32        [required]
	qsfs_disks  []QsfsDisk
	public_ip   bool       [required]
	planetary   bool       [required]
}

[params]
pub struct AddKubernetesNode {
pub:
	deployment_name string     [required]
	name            string     [required]
	node_id         u32        [required]
	cpu             u32        [required]
	memory          u64        [required]
	rootfs_size     u32        [required]
	disk_size       u32        [required]
	qsfs_disks      []QsfsDisk
	public_ip       bool       [required]
	planetary       bool       [required]
}

[params]
pub struct K8S {
pub:
	name        string           [required]
	secret      string           [required]
	network     Network          [required]
	masters     []KubernetesNode [required]
	workers     []KubernetesNode
	metadata    string
	description string
	ssh_key     string           [required]
}

pub struct ZDB {
pub:
	name             string [required]
	node_id          u32    [required]
	mode             string [required]
	disk_size        u32    [required]
	public_namespace bool   [json: 'publicNamespace'; required]
	password         string [required]
}

[params]
pub struct AddZDB {
pub:
	deployment_name  string [required]
	name             string [required]
	node_id          u32    [required]
	mode             string [required]
	disk_size        u32    [required]
	public_namespace bool   [json: 'publicNamespace'; required]
	password         string [required]
}

[params]
pub struct ZDBs {
pub:
	name        string [required]
	zdbs        []ZDB  [required]
	metadata    string
	description string
}

[params]
pub struct QSFSZDBs {
pub:
	name        string [required]
	count       u32    [required]
	node_ids    []u32  [required]
	disk_size   u64    [required]
	password    string [required]
	metadata    string
	description string
}

[params]
pub struct GatewayFQDN {
pub:
	name            string   [required]
	node_id         u32      [required]
	fqdn            string   [required]
	tls_passthrough bool     [required]
	backends        []string [required]
}

[params]
pub struct GatewayName {
pub:
	name            string   [required]
	node_id         u32      [required]
	tls_passthrough bool     [required]
	backends        []string [required]
}

[params]
pub struct NodeContractCreate {
pub:
	node_id   u32    [required]
	hash      string [required]
	data      string [required]
	public_ip u32    [required]
}

[params]
pub struct NodeContractUpdate {
pub:
	id   u64    [required]
	hash string [required]
	data string [required]
}

[params]
pub struct ContractIdByNodeIdAndHash {
pub mut:
	node_id u32    [required]
	hash    string [required]
}

pub struct Contract {
pub:
	version       u32
	contract_id   u64	[json: 'contractId']
	twin_id       u32   [json: 'twinId']
	contract_type ContractTypes [json: 'contractType']
	state         ContractState
}

pub struct SimpleContract {
pub:
	contract_id u64 [json: 'contractId']
}

struct SimpleDeleteContract {
pub:
	contract_id u64
}

struct ContractTypes {
pub:
	node_contract NodeContract [json: 'nodeContract']
	name_contract NameContract [json: 'nameContract']
}

pub struct ListContracts {
pub:
	node_contracts []SimpleContract [json: 'nodeContracts']
	name_contracts []SimpleContract [json: 'nameContracts']
}

struct NodeContract {
pub:
	node_id         u32 [json: 'nodeId']
	deployment_data string [json: 'deploymentData']
	deployment_hash string [json: 'deploymentHash']
	public_ips      u32 [json: 'publicIps']
	public_ips_list []PublicIP [json: 'publicIpsList']
}

struct NameContract {
pub:
	name string
}

struct ContractState {
pub:
	created string
	deleted string
}

struct PublicIP {
pub:
	id          string
	ip          string
	gateway     string
	contract_id u64 [json: 'contractId']
}

pub struct ContractResponse {
pub:
	created []Contract
	updated []Contract
	deleted []SimpleDeleteContract
}

pub struct DeployResponse {
pub:
	contracts        ContractResponse
	wireguard_config string
}

pub struct Env {
pub:
	ssh_key string [json: 'SSH_KEY']
}

[params]
pub struct StellarWallet {
pub mut:
	name    string
	address string
	secret  string
}

pub struct BalanceResult {
pub:
	free        f64
	reserved    f64
	misc_frozen f64 [json: 'miscFrozen']
	fee_frozen  f64 [json: 'feeFrozen']
}

[params]
pub struct BalanceTransfer {
pub:
	address string [required]
	amount  f64    [required]
}

pub struct StellarBalance {
pub:
	asset  string
	amount string
}

[params]
pub struct StellarTransfer {
pub:
	from_name      string [json: 'name'; required]
	target_address string [required]
	amount         f64    [required]
	asset          string = 'TFT'
	memo           string
}

pub struct Twin {
pub:
	version    u32
	id         u32
	account_id string
	ip         string
	entities   []EntityProof
}

struct EntityProof {
	entity_id u32
	signature string
}

[params]
pub struct PagePayload {
pub:
	page       u32 = 1
	max_result u32 [json: 'maxResult'] = 50
}

[params]
pub struct FilterOptions {
pub:
	cru            u32    [omitempty]
	mru            u32    [omitempty]
	sru            u32    [omitempty]
	hru            u32    [omitempty]
	public_ips     bool   [json: 'publicIPs'; omitempty]
	access_node_v4 bool   [json: 'accessNodeV4'; omitempty]
	access_node_v6 bool   [json: 'accessNodeV6'; omitempty]
	gateway        bool   [omitempty]
	farm_id        u32    [json: 'farmId'; omitempty]
	farm_name      string [json: 'farmName']
	country        string
	city           string
}

pub struct Farm {
pub:
	name              string
	farm_id           u32        [json: 'farmId']
	twin_id           u32        [json: 'twinId']
	version           u32
	pricing_policy_id u32        [json: 'pricingPolicyId']
	stellar_address   string     [json: 'stellarAddress']
	public_ips        []PublicIP [json: 'publicIPs']
}

pub struct Node {
pub:
	version            u32
	id                 string
	node_id            u32          [json: 'nodeId']
	farm_id            u32          [json: 'farmId']
	twin_id            u32          [json: 'twinId']
	country            string
	city               string
	grid_version       u32          [json: 'gridVersion']
	uptime             u64
	created            u64
	farming_policy_id  u32          [json: 'farmingPolicyId']
	updated_at         string       [json: 'updatedAt']
	cru                string
	mru                string
	sru                string
	hru                string
	public_config      PublicConfig
	status             string
	certification_type string       [json: 'certificationType']
}

struct PublicConfig {
	domain string
	gw4    string
	gw6    string
	ipv4   string
	ipv6   string
}

pub struct FreeResources {
pub:
	cru   u32
	mru   u64
	hru   u64
	sru   u64
	ipv4u u32
}

pub struct TfChain{
	mut:
		client &TwinClient
}

pub struct Algorand{
	mut:
		client &TwinClient
}

pub struct Stellar{
	mut:
		client &TwinClient
}

pub struct TfchainWalletAddressModel{
	mut:
		address string
}

pub struct TFChainBalanceTransfer {
pub:
	name string
	target_address string 
	amount  f64    
}
pub struct AlgorandBalanceTransfer {
pub:
	sender string
	receiver string
	amount  f64  
	text string
}

pub struct AlgorandAccountImportResponseModel{
	name string
	address string
	mnemonic string
}

pub struct AlgorandAccountAddressModel{
	mut:
		address string
}

pub struct AlgorandAccountMnemonicsModel{
	mut:
		mnemonics string
}

pub struct AlgorandAccountSignBytesResponse{
	mut:
		message string
}