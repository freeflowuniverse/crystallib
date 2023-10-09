module tfgrid

import strconv
import os

pub fn (mut d Deployer) create_node_contract(node_id u32, body string, hash string, public_ips u32, solution_provider u64) !u64 {
	res := os.execute("grid-cli new-node-cn --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --node_id ${node_id} --hash \"${hash}\" --public_ips ${public_ips} --body ${body} --solution_provider ${solution_provider}")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return strconv.parse_uint(res.output, 10, 64)!
}

pub fn (mut d Deployer) create_name_contract(name string) !u64 {
	res := os.execute("grid-cli new-name-cn --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --name ${name}")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return strconv.parse_uint(res.output, 10, 64)!
}

pub fn (mut d Deployer) update_node_contract(contract_id u64, body string, hash string) ! {
	res := os.execute("grid-cli update-cn --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --contract_id ${contract_id} --body \"${body}\" --hash \"${hash}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}
}

pub fn (mut d Deployer) cancel_contract(contract_id u64) ! {
	res := os.execute("grid-cli cancel-cn --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --contract_id ${contract_id}")
	if res.exit_code != 0 {
		return error(res.output)
	}
}
