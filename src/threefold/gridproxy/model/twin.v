module model

pub struct Twin {
pub:
	twin_id    u64    [json: twinId]
	account_id string [json: accountId]
	ip         string
}
