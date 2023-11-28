module stellar

@[params]
pub struct Load {
pub:
	network string = 'public'
	secret  string
}

@[params]
pub struct Transactions {
pub:
	account        string // filter the transactions on the account with the address from this argument, leave empty for your account
	limit          u32    // limit the amount of transactions to gather with this argument, this is 10 by default
	include_failed bool   // include the failed arguments
	cursor         string // list the last transactions starting from this cursor, leave empty to start from the top
	ascending      bool   // order the transactions in ascending order
}

pub struct Transaction {
pub:
	id                      string
	paging_token            string
	successful              bool
	hash                    string
	ledger                  int
	created_at              string
	source_account          string
	account_muxed           string
	account_muxed_id        string
	source_account_sequence string
	fee_account             string
	fee_account_muxed       string
	fee_account_muxed_id    string
	fee_charged             string
	max_fee                 string
	operation_count         int
	enevlope_xdr            string
	result_xdr              string
	result_meta_xdr         string
	fee_meta_xdr            string
	memo                    string
	signatures              []string
	valid_after             string
	valid_before            string
}

pub struct AccountData {
pub:
	id                    string
	account_id            string
	sequence              string
	sequence_ledger       u32
	sequence_time         string
	subentry_count        int
	inflation_destination string
	home_domain           string
	last_modified_ledger  u32
	last_modified_time    string
	thresholds            AccountThresholds
	flags                 AccountFlags
	balances              []Balance
	signers               []Signer
	data                  map[string]string
	num_sponsoring        u32
	num_sponsored         u32
	sponsor               string
	paging_token          string
}

pub struct AccountThresholds {
pub:
	low_threshold  u8
	med_threshold  u8
	high_threshold u8
}

pub struct AccountFlags {
pub:
	auth_required         bool
	auth_revocable        bool
	auth_immutable        bool
	auth_clawback_enabled bool
}

pub struct Balance {
pub:
	balance              string
	liquidity_pool_id    string
	limit                string
	buying_liabilities   string
	selling_liabilities  string
	sponsor              string
	last_modified_ledger u32
	asset_type           string
	asset_code           string
	asset_issuer         string
}

pub struct Signer {
pub:
	weight      int
	key         string
	signer_type string @[json: 'type']
	sponsor     string
}

@[params]
pub struct Swap {
pub:
	amount            string
	source_asset      string = 'xlm'
	destination_asset string
}

@[params]
pub struct Transfer {
pub:
	amount      string
	destination string
	memo        string
}

@[params]
pub struct AccountBalance {
pub:
	address string
	asset   string = 'xlm'
}

@[params]
pub struct BridgeToEth {
pub:
	amount      string
	destination string
}

@[params]
pub struct BridgeToTfchain {
pub:
	amount  string
	twin_id u32
}

@[params]
pub struct AwaitBridgedFromEthereum {
pub:
	memo                            string // the memo to look for
	timeout                         int    // the timeout after which we abandon the search
	amount_of_transactions_to_check int    // how many transactions we check in one go
}
