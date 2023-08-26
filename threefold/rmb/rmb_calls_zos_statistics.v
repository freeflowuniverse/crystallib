module rmb

import json
import encoding.base64

pub struct ZosResources {
pub mut:
	cru   u64
	sru   u64
	hru   u64
	mru   u64
	ipv4u u64
}

pub struct ZosResourcesStatistics {
pub mut:
	total  ZosResources
	used   ZosResources
	system ZosResources
}

// get zos statistic from a node, nodeid is the parameter
pub fn (mut z RMBClient) get_zos_statistics(dst u32) !ZosResourcesStatistics {
	response := z.rmb_request('zos.statistics.get', dst, '')!
	if response.err.message != '' {
		return error('${response.err.message}')
	}
	return json.decode(ZosResourcesStatistics, base64.decode_str(response.dat))!
}
