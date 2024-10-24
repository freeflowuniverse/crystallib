module stellar

pub struct Links {
pub mut:	
	self        Link
	transactions Link
	operations   Link
	payments     Link
	effects      Link
	offers       Link
	trades       Link
	data         Link
}

pub struct Link {
pub mut:	
	href      string
	templated bool
}

pub struct Thresholds {
pub mut:	
	low_threshold  int
	med_threshold  int
	high_threshold int
}

pub struct Flags {
pub mut:	
	auth_required           bool
	auth_revocable          bool
	auth_immutable          bool
	auth_clawback_enabled   bool
}

pub struct Balance {
	pub mut:
	balance                               string
	limit                                 string
	buying_liabilities                    string
	selling_liabilities                   string
	last_modified_ledger                  int
	is_authorized                         bool
	is_authorized_to_maintain_liabilities bool
	asset_type                            string
	asset_code                            string
	asset_issuer                          string
}

pub struct Signer {
pub mut:
	weight int
	key    string
	@type  string
}

@[heap]
pub struct StellarAccount {
pub mut:
	links                 Links
	id                    string
	account_id            string
	sequence              string
	sequence_ledger       int
	sequence_time         string
	subentry_count        int
	last_modified_ledger  int
	last_modified_time    string
	thresholds            Thresholds
	flags                 Flags
	balances              []Balance
	signers               []Signer
	data                  map[string]string
	num_sponsoring        int
	num_sponsored         int
	paging_token          string
}
