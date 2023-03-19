module rmb


//if true the ZOS has a public ip address
pub fn (mut z RMBClient) zos_has_public_config(dst u32) !bool {
	response := z.rmb_client_request('zos.network.public_config_get', dst)!
	if response.err.message != '' {
		return false
	}
	return true
}


pub fn (mut z RMBClient) get_zos_system_version(dst u32) !string {
	response := z.rmb_client_request('zos.system.version', dst)!
	if response.err.message != '' {
		return error('${response.err.message}')
	}
	return base64.decode_str(response.dat)
}

pub fn (mut z RMBClient) get_zos_wg_ports(dst u32) ![]u16 {
	response := z.rmb_client_request('zos.network.list_wg_ports', dst)!
	if response.err.message != '' {
		return error('${response.err.message}')
	}
	return json.decode([]u16, base64.decode_str(response.dat))
}

pub fn (mut z RMBClient) get_storage_pools(dst u32) ![]ZosPool {
	response := z.rmb_client_request('zos.storage.pools', dst)!

	if response.err.message != '' {
		return error('${response.err.message}')
	}
	return json.decode([]ZosPool, base64.decode_str(response.dat))
}
