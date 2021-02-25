module tfgrid

import json
import libsodium
import strconv

pub type WorkloadImpl = Container | Kubernetes | Network | PublicIP | Volume | ZDB

pub fn (w WorkloadImpl) challenge() string {
	return match w {
		Container { w.challenge() }
		Volume { w.challenge() }
		Network { w.challenge() }
		ZDB { w.challenge() }
		Kubernetes { w.challenge() }
		PublicIP { w.challenge() }
	}
}

const (
	container_type  = 'container'
	volume_type     = 'volume'
	network_type    = 'network'
	zdb_type        = 'zdb'
	kubernetes_type = 'kubernetes'
	publicip_type   = 'ipv4'
	workload_types  = map{
		container_type:  WorkloadImpl(Container{})
		volume_type:     WorkloadImpl(Volume{})
		network_type:    WorkloadImpl(Network{})
		zdb_type:        WorkloadImpl(ZDB{})
		kubernetes_type: WorkloadImpl(Kubernetes{})
		publicip_type:   WorkloadImpl(PublicIP{})
	}
	sig_len         = 64
)

// challenger interface allows implementors to generate a challenge that can
// be used for signature input.
pub interface Challenger {
	challenge() string
}

pub struct Volume {
pub mut:
	size  u64
	vtype string [json: 'type']
}

pub fn (volume &Volume) challenge() string {
	return '$volume.size' + '$volume.vtype'
}

pub struct VolumeResult {
pub mut:
	volume_id string
}

pub struct Network {
pub mut:
	name                     string
	network_iprange          string
	subnet                   string
	wg_private_key_encrypted string
	wg_listen_port           u16
	peers                    []Peer
}

pub fn (n &Network) challenge() string {
	mut out := '$n.name'
	out += '$n.network_iprange'
	out += '$n.wg_private_key_encrypted'
	out += '$n.network_iprange'
	for peer in n.peers {
		out += peer.challenge()
	}
	return out
}

pub struct Peer {
pub mut:
	subnet        string
	wg_public_key string
	allowed_ips   []string
	endpoint      string
}

pub fn (peer &Peer) challenge() string {
	mut out := '$peer.wg_public_key' + '$peer.endpoint' + '$peer.subnet'
	for ip in peer.allowed_ips {
		out += '$ip'
	}
	return out
}

pub struct ZDB {
pub mut:
	size      u64
	mode      string
	password  string
	disk_type string
	public    bool
	// plainpassword
}

pub fn (zdb &ZDB) challenge() string {
	return '$zdb.size' + '$zdb.mode' + '$zdb.password' + '$zdb.disk_type' + '$zdb.public'
}

pub struct ZDBResult {
pub mut:
	namespace string
	ips       []string
	port      u32
}

pub struct PublicIP {
pub mut:
	ip string
}

pub fn (ip &PublicIP) challenge() string {
	return '$ip.ip'
}

pub struct Member {
pub mut:
	network_id   string
	ips          []string
	public_ip6   string
	yggdrasil_ip string
}

pub fn (member &Member) challenge() string {
	mut c := '$member.network_id'
	for ip in member.ips {
		c += '$ip'
	}
	c += '$member.public_ip6'
	// TODO: enable this after https://github.com/threefoldtech/zos/issues/868 is done
	// c += '${member.yggdrasil_ip}'
	return c
}

pub struct Mount {
pub mut:
	volume_id  string
	mountpoint string
}

pub fn (mount &Mount) challenge() string {
	return '$mount.volume_id' + '$mount.mountpoint'
}

pub struct Logs {
pub mut:
	logs_type string   [json: 'type']
	data      LogsData
}

pub struct LogsData {
pub mut:
	stdout        string
	stderr        string
	secret_stdout string
	secret_stderr string
}

pub struct Stats {
pub mut:
	stats_type string [json: 'type']
	endpoint   string
}

pub struct ContainerCapacity {
pub mut:
	cpu       u32
	memory    u64
	disk_type string
	disk_size u64
}

pub fn (cp &ContainerCapacity) challenge() string {
	return '$cp.cpu' + '$cp.memory' + '$cp.disk_type' + '$cp.disk_size'
}

pub struct Container {
pub mut:
	flist       string
	hub_url     string
	env         map[string]string
	secretenv   map[string]string
	entrypoint  string
	interactive bool
	mounts      []Mount
	network     Member
	capacity    ContainerCapacity
	logs        []Logs
	stats       []Stats
}

pub fn (c &Container) challenge() string {
	encode_env := fn (input map[string]string) string {
		mut keys := []string{}
		for key, _ in input {
			keys << key
		}
		keys.sort()

		mut out := ''
		for key in keys {
			out += '$key=${input[key]}'
		}

		return out
	}

	mut out := '$c.flist'
	out += '$c.hub_url'
	out += '$c.entrypoint'
	out += '$c.interactive'
	out += encode_env(c.env)
	out += encode_env(c.secretenv)
	for mount in c.mounts {
		out += mount.challenge()
	}
	out += c.network.challenge()
	out += c.capacity.challenge()

	return out
}

pub struct ContainerResult {
pub mut:
	id    string
	ipv6  string
	ipv4  string
	ipygg string
}

pub struct PublicIPResult {
pub mut:
	ip string
}

pub struct Kubernetes {
pub mut:
	size          u16
	networkid     string
	ip            string
	clustersecret string
	masterips     []string
	sshkeys       string
	publicip      string
	// plainclustersecret
}

pub fn (k &Kubernetes) challenge() string {
	mut out := '$k.size'
	out += '$k.clustersecret'
	out += '$k.networkid'
	out += '$k.ip'
	for ip in k.masterips {
		out += '$ip'
	}
	for ssh_key in k.sshkeys {
		out += '$ssh_key'
	}
	out += '$k.publicip'
	return out
}

pub struct KubernetesResult {
pub mut:
	id string
	ip string
}

pub struct Result {
pub mut:
	id        string
	created   int
	state     int
	error     string
	data      string
	signature string
}

pub struct Workload {
pub mut:
	version       int
	id            string
	user          string
	workload_type string [json: 'type']
	data          string
	created       int
	to_delete     bool
	metadata      string
	description   string
	signature     string
	result        Result
}

pub fn (w &Workload) challenge() string {
	mut out := '$w.version'
	out += '$w.user'
	out += '$w.workload_type'
	out += '$w.metadata'
	out += '$w.description'
	// TODO: proper err handling (pass up?)
	data := w.workload_data() or { panic('Failed to get workload data: ' + err) }
	out += data.challenge()

	return out
}

pub fn (w &Workload) workload_data() ?WorkloadImpl {
	mut t := tfgrid.workload_types[w.workload_type] or { return error('unknown workload') }
	match t {
		Container {
			x := json.decode(Container, w.data) or { return error('failed to decode container') }
			t = WorkloadImpl(x)
		}
		Volume {
			x := json.decode(Volume, w.data) or { return error('failed to decode volume') }
			t = WorkloadImpl(x)
		}
		Network {
			x := json.decode(Network, w.data) or { return error('failed to decode network') }
			t = WorkloadImpl(x)
		}
		ZDB {
			x := json.decode(ZDB, w.data) or { return error('failed to decode zdb') }
			t = WorkloadImpl(x)
		}
		Kubernetes {
			x := json.decode(Kubernetes, w.data) or { return error('failed to decode kubernetes') }
			t = WorkloadImpl(x)
		}
		PublicIP {
			x := json.decode(PublicIP, w.data) or { return error('failed to decode public ip') }
			t = WorkloadImpl(x)
		}
	}
	return t
}

pub fn (mut w Workload) sign(sk libsodium.SigningKey) {
	// sig prepends the signature to the plaintext of the input, so split it off
	sig := sk.sign(w.challenge().bytes())[..tfgrid.sig_len]
	w.signature = sig.hex()
	println(w.signature)
}

pub fn (w &Workload) verify(pk libsodium.VerifyKey) ? {
	// verify expects the signature to be sig + plaintext, so reconstruct first	
	mut sig := bytes_from_hex(w.signature)
	sig << w.challenge().bytes()
	println(sig.hex())
	if !pk.verify(sig) {
		return error('invalid signature')
	}
}

// bytes_from_hex converts a hex string into its byte representation. Panics if
// the input is not valid hex.
fn bytes_from_hex(input string) []byte {
	mut out := []byte{len: input.len / 2}
	for i := 0; i < input.len; i += 2 {
		b := strconv.parse_uint(input[i..i + 2], 16, 8)
		out[i / 2] = byte(b)
	}
	return out
}
