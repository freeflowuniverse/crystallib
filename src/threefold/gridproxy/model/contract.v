module model

pub struct ContractBilling {
pub:
	amount_billed     DropTFTUnit [json: amountBilled]
	discount_received string      [json: discountReceived]
	timestamp         UnixTime    [json: timestamp]
}

pub struct NodeContractDetails {
pub:
	node_id              u64    [json: nodeId]
	deployment_data      string [json: deployment_data]
	deployment_hash      string [json: deployment_hash]
	number_of_public_ips u64    [json: number_of_public_ips]
}

pub struct Contract {
pub:
	contract_id   u64                 [json: contractId]
	twin_id       u64                 [json: twinId]
	state         string              [json: state]
	created_at    UnixTime            [json: created_at]
	contract_type string              [json: 'type']
	details       NodeContractDetails [json: details]
	billing       []ContractBilling   [json: billing]
}

// total_billed returns the total amount billed for the contract.
//
// returns: `DropTFTUnit`
pub fn (c &Contract) total_billed() DropTFTUnit {
	if c.billing.len == 0 {
		return 0
	}
	mut total := u64(0)
	for b in c.billing {
		total += b.amount_billed
	}
	return DropTFTUnit(total)
}

// TODO: Implement Limit struct (size, page, retcount, randomize)
// and embeded it in other structs like Contract to avoid duplicated code
// TODO: check if RetCount is bool or string as swagger doc says
// TODO: check if Randomize can be used in the client and where, it is not documnetd in swagger
