module zos

import time

// Deployment operations

// create a new empty deployment
pub fn (client ZOSClient) deployment_create(deployment Deployment) {}

// get deployment by name
pub fn (client ZOSClient) deployment_get(deployment Name) Deployment {}

// delete deployment by name
pub fn (client ZOSClient) deployment_delete(deployment Name) {}

// list deployments
pub fn (client ZOSClient) deployment_list() []Deployment {}

// return the state of the given workloads in that deployment.
// ? can we pass multiple names
// this is needed because any call to one of the _create methods does not mean
// the object has been created but that the request has been accepted and the object
// will be scheduled for creation.
// it means the client either has to poll for state, OR handle "notifications"
// until the workload is ready before it can move on.
pub fn (client ZOSClient) workload_state(deployment Name, workload Name) Workload {}

// list all the "states" of a deployment
pub fn (client ZOSClient) workload_list(deployment Name) []Workload {}

// Network operations

// network_set sets the network on the given deployment
// since you can only have one network per deployment, there is no create
// other calls to network_set will reconfigure the network to match Network
pub fn (client ZOSClient) network_set(deployment Name, network Network) {}

pub fn (client ZOSClient) network_get(deployment Name) Network {}

// VM operations

pub fn (client ZOSClient) vm_create(deployment Name, vm VM) {}

pub fn (client ZOSClient) vm_update(deployment Name, vm VM) {}

pub fn (client ZOSClient) vm_get(deployment Name, vm Name) VM {}

pub fn (client ZOSClient) vm_delete(deployment Name, vm Name) {}

// this is not as simple and i think we should leave it for later,
// and add specific VM update methods that can work on "running vm"
// pub fn (client ZOSClient) vm_update(deployment Name, vm VM) {
// }
// for example
pub fn (client ZOSClient) vm_disk_attach(deployment Name, vm Name, disk Mount) {}

pub fn (client ZOSClient) vm_disk_detach(deployment Name, vm Name, disk Name) {}

// Disk operations

pub fn (client ZOSClient) disk_create(deployment Name, params Disk) {}

pub fn (client ZOSClient) disk_update(deployment Name, params Disk) {}

pub fn (client ZOSClient) disk_get(deployment Name, disk Name) Disk {}

pub fn (client ZOSClient) disk_delete(deployment name, disk Name) {}

// ZDB operations

pub fn (client ZOSClient) zdb_create(deployment Name, zdb Zdb) {}

pub fn (client ZOSClient) zdb_update(deployment Name, zdb Zdb) {}

pub fn (client ZOSClient) zdb_get(deployment Name, zdb Name) Zdb {}

pub fn (client ZOSClient) zdb_delete(deployment Name, zdb Name) {}

// QSFS operations

pub fn (client ZOSClient) qsfs_create(deployment Name, qsfs Qsfs) {}

pub fn (client ZOSClient) qsfs_update(deployment Name, qsfs Qsfs) {}

pub fn (client ZOSClient) qsfs_get(deployment Name, qsfs Name) Qsfs {}

pub fn (client ZOSClient) qsfs_delete(deployment Name, qsfs Name) {}

// Zlog operations

pub fn (client ZOSClient) zlog_create(deployment Name, zlog Zlog) {}

pub fn (client ZOSClient) zlog_update(deployment Name, zlog Zlog) {}

pub fn (client ZOSClient) zlog_get(deployment Name, zlog Name) Zlog {}

pub fn (client ZOSClient) zlog_delete(deployment Name, zlog Name) {}

// gateway FQDN operations

pub fn (client ZOSClient) gateway_fqdn_create(deployment Name, fqdn GatewayFqdn) {}

pub fn (client ZOSClient) gateway_fqdn_update(deployment Name, fqdn GatewayFqdn) {}

pub fn (client ZOSClient) gateway_fqdn_get(deployment Name, fqdn Name) GatewayFqdn {}

pub fn (client ZOSClient) gateway_fqdn_delete(deployment Name, fqdn Name) {}

// gateway name operations

pub fn (client ZOSClient) gateway_name_create(deployment Name, gateway_name GatewayName) {}

pub fn (client ZOSClient) gateway_name_update(deployment Name, gateway_name GatewayName) {}

pub fn (client ZOSClient) gateway_name_get(deployment Name, gateway_name Name) GatewayName {}

pub fn (client ZOSClient) gateway_name_delete(deployment Name, gateway_name Name) {}

// public ip operations

pub fn (client ZOSClient) public_ip_create(deployment Name, public_ip PublicIp) {}

pub fn (client ZOSClient) public_ip_update(deployment Name, public_ip PublicIp) {}

pub fn (client ZOSClient) public_ip_get(deployment Name, public_ip Name) PublicIp {}

pub fn (client ZOSClient) public_ip_delete(deployment Name, public_ip Name) {}
