module tfgrid

[params]
pub struct FilterOptions {
	farm_id u64 // if provided. will filter with farmerbot on this farm. if not will use the normal capacity filter
	public_config bool
	public_ips_count u32
	dedicated bool
	mru u64 // in GB
	hru u64 // in GB
	sru u64 // in GB
}

pub struct FilterResult {
	filter_options FilterOptions
	available_nodes []u32
}

pub fn (mut client TFGridClient) filter_nodes(options FilterOptions) !FilterResult {
	retqueue := client.rpc.call[FilterOptions]('tfgrid.capacity.filterNodes', options)!
	return client.rpc.result[FilterResult](500000, retqueue)!
}