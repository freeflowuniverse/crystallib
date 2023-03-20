module rmb

import base64
import json

// if true the ZOS has a public ip address
pub fn (mut z RMBClient) zos_has_public_ipaddr(dst u32) !bool {
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

// TODO: point to documentation where it explains what this means, what is zos_wg_port and why do we need it
pub fn (mut z RMBClient) get_zos_wg_ports(dst u32) ![]u16 {
	response := z.rmb_client_request('zos.network.list_wg_ports', dst)!
	if response.err.message != '' {
		return error('${response.err.message}')
	}
	return json.decode([]u16{}, base64.decode_str(response.dat))
}
