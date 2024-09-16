module griddriver

import os
import x.json2
import json

pub fn (mut c Client) rmb_call(dst u32, cmd string, payload string) !string {
	res := os.execute("griddriver rmb --cmd '${cmd}' --dst '${dst}' --payload '${payload}' --substrate '${c.substrate}' --mnemonics '${c.mnemonic}' --relay '${c.relay}'")
	if res.exit_code != 0 {
		return error(res.output)
	}
	return res.output
}

pub struct Version {
	zinit string
	zos   string
}

pub fn (mut c Client) get_zos_version(dst u32) !Version {
	data := json.encode('')
	res := c.rmb_call(dst, 'zos.system.version', data)!
	ver := json2.decode[Version](res)!
	return ver
}

pub fn (mut c Client) list_wg_ports(dst u32) ![]u16 {
	res := os.execute("griddriver rmb-taken-ports --dst ${dst} --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --relay \"${c.relay}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}
	return json.decode([]u16, res.output)!
}
