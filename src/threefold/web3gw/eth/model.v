module eth

[params]
pub struct Load {
	url    string
	secret string
}

[params]
pub struct Balance {
	account string
	asset   string = 'eth'
}

[params]
pub struct Transfer {
	destination string // the eth public address of the destination account
	amount      string // how much should be transferred
	asset       string = 'eth' // the asset to transfer to the destination account, default will be eth
}

[params]
pub struct Quote {
	amount            string // the amount that you would like to quote the trade for
	source_asset      string = 'eth' // the source asset
	destination_asset string = 'tft' // the destination asset
}

[params]
pub struct Swap {
	amount            string // the amount to swap
	source_asset      string = 'eth' // the asset to swap to the destination asset
	destination_asset string = 'tft' // the asset you would like to have the source asset be swapped for
}

[params]
pub struct TransferTokens {
	contract_address string
	destination      string
	amount           string
}

[params]
pub struct TransferTokensFrom {
	contract_address string
	from             string // the account where the tokens should come from
	destination      string // the account that will receive the tokens
	amount           string
}

[params]
pub struct ApproveTokenSpending {
	contract_address string
	spender          string // the account that is allowed to spend the tokens
	amount           string // how much that account is allowed to spend
}

[params]
pub struct MultisigOwner {
	contract_address string
	target           string
	threshold        i64
}

[params]
pub struct ApproveHash {
	contract_address string
	hash             string
}

[params]
pub struct InitiateMultisigEthTransfer {
	contract_address string
	destination      string
	amount           string
}

[params]
pub struct InitiateMultisigTokenTransfer {
	contract_address string
	token_address    string
	destination      string
	amount           string
}

[params]
pub struct GetFungibleBalance {
	contract_address string
	target           string
}

[params]
pub struct OwnerOfFungible {
	contract_address string
	token_id         i64
}

[params]
pub struct TransferFungible {
	contract_address string
	from             string
	to               string
	token_id         i64
}

[params]
pub struct SetFungibleApproval {
	contract_address string
	from             string
	to               string
	amount           i64
}

[params]
pub struct SetFungibleApprovalForAll {
	contract_address string
	from             string
	to               string
	approved         bool
}

[params]
pub struct ApprovalForFungible {
	contract_address string
	owner            string
	operator         string
}

[params]
pub struct BridgeToStellar {
	destination string // the eth public address of the destination account
	amount      string // how much should be transfered
}
