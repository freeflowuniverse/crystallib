module zos

import time


struct Deployment {
	name         Name
	// probably not needed in v4 since we will use micro payments
	// directly against twin
	contracts_id string
	metadata     string
	description  string
}

// create a new empty deployment
pub fn (client ZOSClient) deployment_create(deployment Deployment) {
}

// get deployment by name
pub fn (client ZOSClient) deployment_get(deployment Name) Deployment {
}

pub fn (client ZOSClient) deployment_list() []Deployment {
}

// return the state of the given workloads in that deployment.
// ? can we pass multiple names
// this is needed because any call to one of the _create methods does not mean
// the object has been created but that the request has been accepted and the object
// will be scheduled for creation.
// it means the client either has to poll for state, OR handle "notifications"
// until the workload is ready before it can move on.
pub fn (client ZOSClient) workload_state(deployment Name, name Name) Workload {

}

// list all the "states" of a deployment
pub fn (client ZOSClient) workload_list(deployment Name) []Workload {

}

// deployment_network_set sets the network on the given deployment
// since you can only have one network per deployment, there is no create
// other calls to nework_set will reconfigure the network to match Network
pub fn (client ZOSClient) network_set(params Network) {
}

pub fn (client ZOSClient) network_get(deployment Name) Network {
}


pub fn (client ZOSClient) vm_create(deployment Name, vm VM) {
}


// this is not as simple and i think we should leave it for later,
// and add specific VM update methods that can work on "running vm"
// pub fn (client ZOSClient) deployment_vm_update(deployment Name, vm VM) {
// }
// for example

pub fn (client ZOSClient) vm_disk_attach(deployment Name, vm Name, disk Mount) {
}

pub fn (client ZOSClient) vm_disk_detach(deployment Name, vm Name, disk Name) {
}

pub fn (client ZOSClient) vm_get(deployment Name, vm Name) {
}

pub fn (client ZOSClient) vm_delete(deployment Name, vm Name) {
}


pub fn (client ZOSClient) disk_create(deployment Name, params Disk) {
}

pub fn (client ZOSClient) disk_update(deployment Name, params Disk) {
}

pub fn (client ZOSClient) disk_get(deployment Name, disk Name) Disk {
}

pub fn (client ZOSClient) disk_delete(deployment name, disk Name) {
}

struct ZdbCreateParams {
	deployment_name string  // deployment name
	name            string  // zdb name
	version         u32     // deployment version
	mode            ZDBMode // zdb mode
	size            Unit    // zdb size in GB
	password        string  //
	public          bool    // if zdb gets a public ip6
}

pub fn (client ZOSClient) deployment_zdb_create(params ZdbCreateParams) {
}

struct ZdbUpdateParams {
	deployment_name string  // deployment name
	name            string  // zdb name
	version         u32     // deployment version
	mode            ZDBMode // zdb mode
	size            Unit    // zdb size in GB
	password        string  //
	public          bool    // if zdb gets a public ip6
}

pub fn (client ZOSClient) deployment_zdb_update(params ZdbUpdateParams) {
}

struct ZdbGetParams {
	deployment_name string // deployment name
	name            string // zdb name
}

pub fn (client ZOSClient) deployment_zdb_get(params ZdbGetParams) {
}

struct ZdbDeleteParams {
	deployment_name string // deployment name
	name            string // zdb name
}

pub fn (client ZOSClient) deployment_zdb_delete(params ZdbDeleteParams) {
}

struct QsfsParams {
	deployment_name       string             // deployment name
	name                  string             // qsfs name
	version               u32                // deployment version
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

pub fn (client ZOSClient) deployment_qsfs_create(params QsfsParams) {
}

pub fn (client ZOSClient) deployment_qsfs_update(params QsfsParams) {
}

struct QsfsGetParams {
	deployment_name string // deployment name
	name            string // qsfs name
}

pub fn (client ZOSClient) deployment_qsfs_get(params QsfsGetParams) {
}

struct ZlogParams {
	deployment_name string // deployment name
	name            string // zlog name
	version         u32    // deployment version
	vm_name         string // vm name
	output          string // zlog output
}

pub fn (client ZOSClient) deployment_zlog_create(params ZlogParams) {
}

pub fn (client ZOSClient) deployment_zlog_update(params ZlogParams) {
}

struct ZlogGetParams {
	deployment_name string // deployment name
	name            string // zlog name
}

pub fn (client ZOSClient) deployment_zlog_get(params ZlogGetParams) {
}

struct ZlogDeleteParams {
	deployment_name string // deployment name
	name            string // zlog name
}

pub fn (client ZOSClient) deployment_zlog_delete(params ZlogDeleteParams) {
}

struct GatewayFqdnParams {
	deployment_name string    // deployment name
	name            string    // gateway name
	version         string    // deployment version
	fqdn            string    // fqdn
	tls_passthrough string    // tls passthrough is optional
	network         string    // gateway network
	backends        []Backend // ["list of backends"]
}

pub fn (client ZOSClient) deployment_gateway_fqdn_create(params GatewayFqdnParams) {
}

pub fn (client ZOSClient) deployment_gateway_fqdn_update(params GatewayFqdnParams) {
}

struct GatewayFqdnGetParams {
	deployment_name string // deployment name
	name            string // gateway name
}

pub fn (client ZOSClient) deployment_gateway_fqdn_get(params GatewayFqdnGetParams) {
}

struct GatewayNameParams {
	deployment_name string    // deployment name
	name            string    // gateway name
	version         u32       // deployment version
	tls_passthrough bool      // tls passthrough is optional
	network         string    // gateway network
	backends        []Backend // ["list of backends"]
}

pub fn (client ZOSClient) deployment_gateway_name_create(params GatewayNameParams) {
}

type Backend = string

pub fn (client ZOSClient) deployment_gateway_name_update(params GatewayNameParams) {
}

struct GatewayNameGetParams {
	deployment_name string // deployment name
	name            string // gateway name
}

pub fn (client ZOSClient) deployment_gateway_name_get(params GatewayNameGetParams) {
}

struct PublicIpParams {
	deployment_name string // deployment name
	name            string // public_ip name
	version         u32    // deployment version
	ipv4            bool   // if you want an ipv4
	ipv6            bool   // if you want an ipv6
}

pub fn (client ZOSClient) deployment_public_ip_create(params PublicIpParams) {
}

pub fn (client ZOSClient) deployment_public_ip_update(params PublicIpParams) {
}

struct PublicIpGetParams {
	deployment_name string // deployment name
	name            string // public_ip name
}

pub fn (client ZOSClient) deployment_public_ip_get(params PublicIpGetParams) {
}

struct PublicIpDeleteParams {
	deployment_name string // deployment name
	name            string // public_ip name
}

pub fn (client ZOSClient) deployment_public_ip_delete(params PublicIpDeleteParams) {
}
