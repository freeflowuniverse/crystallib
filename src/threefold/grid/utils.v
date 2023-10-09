module tfgrid

import strconv
import os

pub fn get_user_twin(mnemonics string, substrate_url string) !u32 {
	res := os.execute("grid-cli user-twin --mnemonics \"${mnemonics}\" --substrate \"${substrate_url}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return u32(strconv.parse_uint(res.output, 10, 32)!)
}

pub fn get_node_twin(node_id u64, substrate_url string) !u32 {
	res := os.execute('grid-cli node-twin --substrate ${substrate_url}  --node_id ${node_id}')
	if res.exit_code != 0 {
		return error(res.output)
	}

	return u32(strconv.parse_uint(res.output, 10, 32)!)
}
