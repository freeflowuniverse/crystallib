module griddriver

import os
import strconv
import freeflowuniverse.crystallib.ui.console

pub fn (mut c Client) get_node_twin(node_id u64) !u32 {
	res := os.execute("griddriver node-twin --substrate \"${c.substrate}\"  --node_id ${node_id}")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return u32(strconv.parse_uint(res.output, 10, 32)!)
}

pub fn (mut c Client) get_user_twin() !u32 {
	res := os.execute("griddriver user-twin --mnemonics \"${c.mnemonic}\" --substrate \"${c.substrate}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return u32(strconv.parse_uint(res.output, 10, 32)!)
}

pub fn (mut c Client) create_node_contract(node_id u32, body string, hash string, public_ips u32, solution_provider u64) !u64 {
	console.print_debug('url: ${c.substrate}')
	res := os.execute("griddriver new-node-cn --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --node_id ${node_id} --hash \"${hash}\" --public_ips ${public_ips} --body \"${body}\" --solution_provider ${solution_provider}")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return strconv.parse_uint(res.output, 10, 64)!
}

pub fn (mut c Client) create_name_contract(name string) !u64 {
	res := os.execute("griddriver new-name-cn --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --name ${name}")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return strconv.parse_uint(res.output, 10, 64)!
}

pub fn (mut c Client) update_node_contract(contract_id u64, body string, hash string) ! {
	res := os.execute("griddriver update-cn --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --contract_id ${contract_id} --body \"${body}\" --hash \"${hash}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}
}

pub fn (mut c Client) cancel_contract(contract_id u64) ! {
	res := os.execute("griddriver cancel-cn --substrate \"${c.substrate}\" --mnemonics \"${c.mnemonic}\" --contract_id ${contract_id}")
	if res.exit_code != 0 {
		return error(res.output)
	}
}
