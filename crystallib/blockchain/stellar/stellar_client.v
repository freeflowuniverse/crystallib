module stellar

import os

pub struct StellarAccountKeys {
pub:
	name       string
	public_key string
	secret_key string
}

// TODO: work with enum for network

pub struct StellarClient {
pub mut:
	network         string
	default_assetid string // default asset contract ID, can be empty
	default_from    string // default account to work default_from, can be empty
	default_account string // default name of the account
}

@[params]
pub struct StellarClientConfig {
pub:
	network         string
	default_assetid string // contract id of the asset
	default_from    string
	default_account string // default name of the account
}

pub fn new_stellar_client(config StellarClientConfig) !StellarClient {
	mut cl := StellarClient{
		network: config.network
		default_assetid: config.default_assetid
		default_from: config.default_from
		default_account: config.default_account
	}
	if cl.default_assetid == '' {
		cl.default_assetid = cl.default_assetid_get()!
	}
	return cl
}

@[params]
pub struct AddKeysArgs {
pub:
	source_account_name ?string
	secret              string
}

pub fn (mut client StellarClient) add_keys(args AddKeysArgs) ! {
	mut account_name := client.default_account

	if v := args.source_account_name {
		account_name = v
	}

	cmd := 'SOROBAN_SECRET_KEY=${args.secret} stellar keys add ${account_name} --secret-key'
	result := os.execute(cmd)
	if result.exit_code != 0 {
		return error('Failed to add keys: ${result.output}')
	}
}

pub fn (mut client StellarClient) account_new(name string) !StellarAccountKeys {
	// Generate the keys
	result := os.execute('stellar keys generate ${name} --network ${client.network}')
	if result.exit_code != 0 {
		return error('Failed to generate keys: ${result.output}')
	}

	return client.account_keys_get(name)
}

pub fn (mut client StellarClient) account_keys_get(name string) !StellarAccountKeys {
	// Get the public key
	address_result := os.execute('stellar keys address ${name} --quiet')
	if address_result.exit_code != 0 {
		return error('Failed to get public key: ${address_result.output}')
	}
	public_key := address_result.output.trim_space()

	// Get the secret key
	show_result := os.execute('stellar keys show ${name} --quiet')
	if show_result.exit_code != 0 {
		return error('Failed to get secret key: ${show_result.output}')
	}
	secret_key := show_result.output.trim_space()

	// Return the StellarAccountKeys struct
	return StellarAccountKeys{
		name: name
		public_key: public_key
		secret_key: secret_key
	}
}

pub fn (mut client StellarClient) account_fund(name string) !u64 {
	result := os.execute('stellar keys fund ${name} --network ${client.network}')
	if result.exit_code != 0 {
		return error('Failed to fund account, maybe you are not on testnet: ${result.output}')
	}

	// TODO: check funding is there and return

	return 0
}

pub fn (mut client StellarClient) default_assetid_get() !string {
	result := os.execute('stellar contract id asset --asset native --network ${client.network}')
	if result.exit_code != 0 {
		return error('Failed to get asset contract ID: ${result.output}')
	}
	return result.output.trim_space()
}

@[params]
pub struct SendPaymentParams {
	default_assetid string
	default_from    string
	to              string
	amount          f64
}

pub fn (mut client StellarClient) payment_send(params SendPaymentParams) !string {
	asset_id := if params.default_assetid == '' {
		client.default_assetid
	} else {
		params.default_assetid
	}
	default_from := if params.default_from == '' { client.default_from } else { params.default_from }
	cmd := 'stellar contract invoke --id ${asset_id} --source-account ${default_from} --network ${client.network} -- transfer --to ${params.to} --default_from ${default_from} --amount ${params.amount}'
	result := os.execute(cmd)
	if result.exit_code != 0 {
		return error('Failed to send payment: ${result.output}')
	}
	return result.output.trim_space()
}

@[params]
pub struct CheckBalanceParams {
	assetid    string
	account_id string
}

pub fn (mut client StellarClient) balance_check(params CheckBalanceParams) !string {
	asset_id := if params.assetid == '' { client.default_assetid } else { params.assetid }
	cmd := 'stellar contract invoke --id ${asset_id} --source-account ${params.account_id} --network ${client.network} -- balance --id ${params.account_id}'
	result := os.execute(cmd)
	if result.exit_code != 0 {
		return error('Failed to check balance: ${result.output}')
	}
	return result.output.trim_space()
}

@[params]
pub struct MergeArgs {
pub:
	source_account_name ?string
	address             string
}

pub fn (mut client StellarClient) merge_accounts(args MergeArgs) ! {
	mut account_name := client.default_account

	if v := args.source_account_name {
		account_name = v
	}

	account_keys := client.account_keys_get(account_name)!
	cmd := 'stellar tx new account-merge --source-account ${account_keys.secret_key} --account ${args.address} --network ${client.network}'
	result := os.execute(cmd)
	if result.exit_code != 0 {
		return error('Failed to add keys: ${result.output}')
	}
}
