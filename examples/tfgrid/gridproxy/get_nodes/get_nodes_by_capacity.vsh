#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.ui.console


// * `available_for` (u64): Available for twin id. [optional].
// * `certification_type` (string): Certificate type NotCertified, Silver or Gold. [optional].
// * `city_contains` (string): Node partial city filter. [optional].
// * `city` (string): Node city filter. [optional].
// * `country_contains` (string): Node partial country filter. [optional].
// * `country` (string): Node country filter. [optional].
// * `dedicated` (bool): Set to true to get the dedicated nodes only. [optional].
// * `domain` (string): Set to true to filter nodes with domain. [optional].
// * `farm_ids` ([]u64): List of farm ids. [optional].
// * `farm_name_contains` (string): Get nodes for specific farm. [optional].
// * `farm_name` (string): Get nodes for specific farm. [optional].
// * `free_hru` (u64): Min free reservable hru in bytes. [optional].
// * `free_ips` (u64): Min number of free ips in the farm of the node. [optional].
// * `free_mru` (u64): Min free reservable mru in bytes. [optional].
// * `free_sru` (u64): Min free reservable sru in bytes. [optional].
// * `gpu_available` (bool): Filter nodes that have available GPU. [optional].
// * `gpu_device_id` (string): Filter nodes based on GPU device ID. [optional].
// * `gpu_device_name` (string): Filter nodes based on GPU device partial name. [optional].
// * `gpu_vendor_id` (string): Filter nodes based on GPU vendor ID. [optional].
// * `gpu_vendor_name` (string): Filter nodes based on GPU vendor partial name. [optional].
// * `has_gpu`: Filter nodes on whether they have GPU support or not. [optional].
// * `ipv4` (string): Set to true to filter nodes with ipv4. [optional].
// * `ipv6` (string): Set to true to filter nodes with ipv6. [optional].
// * `node_id` (u64): Node id. [optional].
// * `page` (u64): Page number. [optional].
// * `rentable` (bool): Set to true to filter the available nodes for renting. [optional].
// * `rented_by` (u64): Rented by twin id. [optional].
// * `ret_count` (bool): Set nodes' count on headers based on filter. [optional].
// * `size` (u64): Max result per page. [optional].
// * `status` (string): Node status filter, set to 'up' to get online nodes only. [optional].
// * `total_cru` (u64): Min total cru in bytes. [optional].
// * `total_hru` (u64): Min total hru in bytes. [optional].
// * `total_mru` (u64): Min total mru in bytes. [optional].
// * `total_sru` (u64): Min total sru in bytes. [optional].
// * `twin_id` (u64): Twin id. [optional].


// Default value used in intializing the resources

mut myfilter := gridproxy.nodefilter()

myfilter.free_sru_gb = 1
myfilter.free_ips = 1
myfilter.free_hru_gb = 1
myfilter.free_mru_gb = 1

//network: dev, test, qa or main
mut gp_client := gridproxy.get(network:.main, cache:false)!
mynodes := gp_client.get_nodes(filter:myfilter)!

console.print_debug("${mynodes}")
	
