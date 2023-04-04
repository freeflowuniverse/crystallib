module tfgrid

[params]
pub struct MachinesModel {
pub:
	name        string    [required]
	network     Network   [required]
	machines    []Machine [required]
	metadata    string
	description string
}

pub struct MachinesResult {
pub:
	name        string
	metadata    string
	description string
	network     NetworkResult
	machines    []MachineResult
}

[params]
pub struct Machine {
pub:
	name        string            [required]
	node_id     u32               [required]
	flist       string = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string = '/sbin/zinit init'
	public_ip   bool
	public_ip6  bool
	planetary   bool = true
	cpu         u32  = 1 // number of vcpu cores
	memory      u64  = 1024 // in MBs
	rootfs_size u64 // in MBs
	zlogs       []Zlog
	disks       []Disk
	qsfs        []QSFS
	env_vars    map[string]string // ex: { "SSH_KEY": ".." }
	description string
}

struct MachineResult {
pub:
	name        string
	node_id     u32
	flist       string
	entrypoint  string
	public_ip   bool
	public_ip6  bool
	planetary   bool
	cpu         u32
	memory      u64
	rootfs_size u64
	zlogs       []Zlog
	disks       []DiskResult
	qsfs        []QSFSResult
	env_vars    map[string]string
	description string
	// computed
	computed_ip4 string
	computed_ip6 string
	wireguard_ip string
	ygg_ip       string
}

[params]
pub struct Disk {
pub:
	size        u32    [required] // disk size in GBs
	mountpoint  string [required]
	description string
}

[params]
pub struct DiskResult {
pub:
	size        u32    [required] // disk size in GBs
	mountpoint  string [required]
	description string
	// computed
	name string [required]
}

[params]
pub struct QSFS {
pub:
	name             string [required]
	mountpoint       string [required]
	qsfs_zdbs_name   string [required]
	encryption_key   string [required]
	cache            u32    [required]
	minimal_shards   u32    [required]
	expected_shards  u32    [required]
	redundant_groups u32    [required]
	redundant_nodes  u32    [required]

	encryption_algorithm  string = 'AES'
	compression_algorithm string = 'snappy'
	metadata              Metadata [required]
	description           string

	max_zdb_data_dir_size u32     [required]
	groups                []Group [required]
}

pub struct QSFSResult {
pub:
	name             string
	mountpoint       string
	qsfs_zdbs_name   string
	encryption_key   string
	cache            u32
	minimal_shards   u32
	expected_shards  u32
	redundant_groups u32
	redundant_nodes  u32

	encryption_algorithm  string
	compression_algorithm string
	metadata              Metadata
	description           string

	max_zdb_data_dir_size u32
	groups                []Group
	// computed
	metrics_endpoint string
}

[params]
pub struct Zlog {
pub:
	output string
}

pub struct Metadata {
	type_                string    [json: 'type'] = 'zdb'
	prefix               string    [required]
	encryption_algorithm string = 'AES'
	encryption_key       string    [required]
	backends             []Backend
}

pub struct Group {
	backends []Backend
}

pub struct Backend {
	address   string [required]
	namespace string [required]
	password  string [required]
}

pub struct Network {
pub:
	ip_range             string = '10.1.0.0/16'
	add_wireguard_access bool
}

struct NetworkResult {
pub:
	name     string
	ip_range string
	// computed
	wireguard_config string
}

struct AddMachine {
	machine      Machine
	project_name string
}

struct RemoveMachine {
	machine_name string
	project_name string
}
