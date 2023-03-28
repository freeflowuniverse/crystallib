module tfgrid

pub struct Node {
pub:
	version            u32
	id                 string
	node_id            u32          [json: 'nodeId']
	farm_id            u32          [json: 'farmId']
	twin_id            u32          [json: 'twinId']
	country            string
	city               string
	grid_version       u32          [json: 'gridVersion']
	uptime             u64
	created            u64
	farming_policy_id  u32          [json: 'farmingPolicyId']
	updated_at         string       [json: 'updatedAt']
	cru                string
	mru                string
	sru                string
	hru                string
	// public_config      PublicConfig
	status             string
	certification_type string       [json: 'certificationType']
}

// todo: here we translate json, maybe can be done at golang side

// what is purpose of this one!
