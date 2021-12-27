module twinclient

[params]
pub struct SingleDelete{
	name string [required]
	deployment_name string [required]
}

pub struct Disk {
	name       string [required]
	size       u32 [required]
	mountpoint string [required]
}

[params]
pub struct QsfsDisk {
	qsfs_zdbs_name string [required]
	name string [required]
	prefix string [required]
	encryption_key string [required]
	cache u32
	minimal_shards u32
	expected_shards u32
	mountpoint string [required]
}

pub struct Network {
	ip_range string [required]
	name     string	[required]
	add_access bool [json: 'addAccess']
}

pub struct Machine {
pub:
	name        string [required]
	node_id     u32 [required]
	disks       []Disk
	qsfs_disks  []QsfsDisk
	public_ip   bool [required]
	planetary   bool [required]
	cpu         u32 [required]
	memory      u64 [required]
	rootfs_size u64 [required]
	flist       string [required]
	entrypoint  string [required]
	env         Env
}

[params]
pub struct AddMachine {
pub:
	deployment_name string [required]
	name        string [required]
	node_id     u32 [required]
	disks       []Disk
	qsfs_disks  []QsfsDisk
	public_ip   bool [required]
	planetary   bool [required]
	cpu         u32 [required]
	memory      u64 [required]
	rootfs_size u64 [required]
	flist       string [required]
	entrypoint  string [required]
	env         Env
}

[params]
pub struct Machines {
	name        string [required]
	network     Network [required]
	machines    []Machine [required]
	metadata    string
	description string
}

pub struct KubernetesNode {
pub:
	name            string [required]
	node_id         u32 [required]
	cpu             u32 [required]
	memory          u64 [required]
	rootfs_size     u32 [required]
	disk_size       u32 [required]
	qsfs_disks      []QsfsDisk
	public_ip       bool [required]
	planetary   bool [required]
}

[params]
pub struct AddKubernetesNode {
pub:
	deployment_name string [required]
	name            string [required]
	node_id         u32 [required]
	cpu             u32 [required]
	memory          u64 [required]
	rootfs_size     u32 [required]
	disk_size       u32 [required]
	qsfs_disks      []QsfsDisk
	public_ip       bool [required]
	planetary       bool [required]
}

[params]
pub struct K8S {
pub:
	name        string [required]
	secret      string [required]
	network     Network [required]
	masters     []KubernetesNode [required]
	workers     []KubernetesNode
	metadata    string
	description string
	ssh_key     string [required]
}

pub struct ZDB {
pub:
	name            string [required]
	node_id         u32 [required]
	mode            string [required]
	disk_size       u32 [required]
	public_namespace bool [required;json: 'publicNamespace']
	password        string [required]
}

[params]
pub struct AddZDB{
	deployment_name string [required]
	name            string [required]
	node_id         u32 [required]
	mode            string [required]
	disk_size       u32 [required]
	public_namespace bool [required;json: 'publicNamespace']
	password        string [required]
}

[params]
pub struct ZDBs {
pub:
	name        string [required]
	zdbs        []ZDB [required]
	metadata    string
	description string
}


pub struct GatewayFQDN {
	name string [required]
	node_id u32 [required]
	fqdn string [required]
	tls_passthrough bool [required]
	backends []string [required]
}

pub struct GatewayName {
	name string [required]
	node_id u32 [required]
	tls_passthrough bool [required]
	backends []string [required]
}

pub struct Contract {
pub:
	version         u32
	contract_id     u64
	twin_id         u32
	node_id         u32
	deploy_mentdata string
	deployment_hash string
	public_ips      u32
	state           string
	public_ips_list []PublicIP
}

struct PublicIP {
	ip          string
	gateway     string
	contract_id u64
}

pub struct ContractDeployResponse {
	created []Contract
	updated []Contract
	deleted []Contract
}

pub struct DeployResponse {
	contracts        ContractDeployResponse
	wireguard_config string
}

pub struct Env {
	ssh_key string [json: 'SSH_KEY']
}

pub struct StellarWallet {
pub mut:
	name    string
	address string
	secret  string
}

pub struct BalanceResult{
	free f64
	reserved f64
	misc_frozen f64 [json: 'miscFrozen']
	fee_frozen f64 [json: 'feeFrozen']
}

[params]
pub struct BalanceTransfer{
	address string [required]
	amount  f64 [required]
}


pub struct StellarBalance{
	asset string
	amount f64
}

[params]
pub struct StellarTransfer{
	from_name string [required;json: "name"]
	target_address string [required]
	amount f64 [required]
	asset string = 'TFT'
	memo string
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
