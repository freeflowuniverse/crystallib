module griddriver

import os
import x.json2

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
	res := c.rmb_call(dst, 'zos.system.version', '')!
	ver := json2.decode[Version](res)!
	return ver
}
