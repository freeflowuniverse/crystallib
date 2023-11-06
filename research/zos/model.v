module zos

// Generic object name
// name must be a valid object name (validation?)
type Name = string

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
	subnet        IPNet
	wireguard_public_key string
	allowed_ips   []IPNet
	endpoint      string
}

struct Network {
	description           string // network description
	ip_range              IPNet // network ip range
	subnet                IPNet  // network subnet
	wireguard_private_key string // network private key
	wireguard_listen_port u16    // network listen port
	peers                 []Peer // ["network list of peers"]
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

enum State {
	init,
	ok,
	error,
	paused
}

struct Workload {
	name   string
	kind   string
	err    string
	state  State
	data   any // kind specific data
}
