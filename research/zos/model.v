module zos

// Generic object name
// name must be a valid object name (validation?)
type Name = string

// Deployment will hold any user deployments (contracts)
struct Deployment {
	name         Name
	// probably not needed in v4 since we will use micro payments
	// directly against twin
	contracts_id string
	metadata     string
	description  string
	twin_id      u16
}

// IPNet is a subnet always in the CIDR format <ip>/mask
// it's up to implementation to deserialize that into
// usable lanuage specific types
type IPNet = string

// Unit defines a capacity unit in "bytes"
// Any "value" of type Unit must be in bytes only
// hence use the Unit mutliplies below to set the
// write value
type Unit = u64

// Peer is the description of a peer of a NetResource
struct Peer {
	subnet               IPNet
	wireguard_public_key string
	allowed_ips          []IPNet
	endpoint             string
}

struct Network {
	description           string // network description
	ip_range              IPNet // network ip range
	subnet                IPNet  // network subnet
	wireguard_private_key string // network private key
	wireguard_listen_port u16    // network listen port
	peers                 []Peer // ["network list of peers"]
	metadata              NetworkMetadata // network metadata

}

struct NetworkMetadata {
	User_access_ip string 
	private_key    string 
	public_node_id u32 
}

struct Disk {
	name            string // disk name
	description     string // disk description
	size            Unit   // disk size
}


// Capacity the expected capacity of a workload
struct Capacity {
	cru   u64
	sru   Unit
	hru   Unit
	mru   Unit
	// ipv4u u64
}

struct VM {
	name            Name   // vm name
	description     string   // vm description
	flist           string   // vm flist
	// network is not needed it can only be the deployment
	// network. We don't have to reference it by name anymore
	// what to do if deployment have no network ?
	// NOTE: this might change later during development
	// if we need to support other networking modes
	// network        bool   // vm network

	size            Unit     // disk size in GB
	capacity        Capacity // cpu and memory
	mounts          []Mount  // [{"name":"mount name","point":"mount point"}]
	entrypoint      string   // vm entry point
	env             map[string]string // {"key":"value"}
	corex           bool  // vm corex
	gpus            []GPU // ["vm list of gpus"]
}

type GPU = string

struct Mount {
	// Name of the `disk` object in deployment
	name  Name
	// target mount point
	target string
}

type ZDBMode = string

struct ZDBGroup {
	backends []ZDBBackend
}

struct ZDBBackend {
	address   string
	namespace string
	password  string
}

struct Zdb {
	name            string  // zdb name
	mode            ZDBMode // zdb mode
	size            Unit    // zdb size in GB
	password        string  //
	public          bool    // if zdb gets a public ip6
}

struct QuantumSafeMeta {
	typ_   string            [json: 'type']
	config QuantumSafeConfig
}

struct QuantumSafeConfig {
	prefix     string
	encryption Encryption
	backends   []ZDBBackend
}

struct Encryption {
	algorithm EncryptionAlgorithm
	key       EncryptionKey
}

type EncryptionAlgorithm = string
type EncryptionKey = []byte

struct QuantumCompression {
	algorithm string
}

struct Qsfs {
	name                  string             // qsfs name
	cache                 Unit               // qsfs cache
	minimal_shards        u32                // qsfs minimal shards
	expected_shards       u32                // qsfs expected shards
	redundant_groups      u32                // qsfs redundant groups
	redundant_nodes       u32                // qsfs redundant nodes
	max_zdb_data_dir_size u32                // qsfs max zdb data dir size
	encryption            Encryption         // qsfs encryption
	metadata              QuantumSafeMeta    // qsfs metadata
	groups                []ZDBGroup         // qsfs groups
	compression           QuantumCompression // qsfs compression
}

struct Zlog {
	name            string // zlog name
	vm_name         string // vm name
	output          string // zlog output
}

type Backend = string

struct GatewayFqdn {
	name            string    // gateway name
	fqdn            string    // fqdn
	tls_passthrough string    // tls passthrough is optional
	network         string    // gateway network
	backends        []Backend // ["list of backends"]
}

struct GatewayName {
	name            string    // gateway name
	tls_passthrough bool      // tls passthrough is optional
	network         string    // gateway network
	backends        []Backend // ["list of backends"]
}

struct PublicIp {
	name            string // public_ip name
	ipv4            bool   // if it contains an ipv4
	ipv6            bool   // if it contains an ipv6
}

enum State {
	init
	ok
	error
	paused
}

struct Workload {
	name    string
	kind    string
	err     string
	version u16
	state   State
	data    any // kind specific data
}
