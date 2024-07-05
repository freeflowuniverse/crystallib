module griddriver

import os
import freeflowuniverse.crystallib.threefold.grid.models

pub fn (mut c Client) sign_deployment(hash string) !string {
	res := os.execute("griddriver sign --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --hash \"${hash}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}
	return res.output
}

pub fn (mut c Client) deploy_single_vm(node_id u32, solution_type string, vm models.VM, env string) !string {
	data := vm.json_encode()
	res := os.execute("griddriver deploy-single --mnemonics \"${c.mnemonic}\" --env ${env} --solution_type \"${solution_type}\" --node ${node_id} --data '${data}'")
	return res.output
}

// returns priv, pub key separated by a space
pub fn (mut c Client) generate_wg_priv_key() ![]string {
	res := os.execute('griddriver generate-wg-key')
	key := res.output.split(' ')
	if key.len != 2 {
		return error('could not generate private key: ${res.output}')
	}
	return key
}
