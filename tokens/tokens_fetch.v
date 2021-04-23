module tokens

import json
import net.http
import strconv
import despiegk.crystallib.redisclient

//
// Raw JSON struct
//
struct Raw_Wallet {
	address string
	description string
	liquid bool
	amount string
}

struct Raw_FoundationAccountInfo {
	category string
	wallets []Raw_Wallet
}

struct Raw_StatsTFT {
	total_tokens string
	total_accounts string
	total_locked_tokens string
	total_vested_tokens string
	total_liquid_foundation_tokens string
	total_illiquid_foundation_tokens string
	total_liquid_tokens string
	foundation_accounts_info []Raw_FoundationAccountInfo
	locked_tokens_info []string
}

struct Raw_Balance {
	amount string
	asset string
}

struct Raw_Account {
	address string
	balances []Raw_Balance
	vesting_accounts []Raw_VestingAccount
	locked_amounts []Raw_LockedAmount
}

struct Raw_VestingAccount {
	address string
	vestingscheme string
	balances []Raw_Balance
}

struct Raw_LockedAmount {
	address string
	locked_until string
	balances []Raw_Balance
}


//
// Improved struct
//
struct Wallet {
pub mut:
	address string
	description string
	liquid bool
	amount f64
}

struct FoundationAccountInfo {
pub mut:
	category string
	wallets []Wallet
}

struct LockedTokensInfo {
pub mut:
	amount f64
	until string
}

struct StatsTFT {
pub mut:
	total_tokens f64
	total_accounts f64
	total_locked_tokens f64
	total_vested_tokens f64
	total_liquid_foundation_tokens f64
	total_illiquid_foundation_tokens f64
	total_liquid_tokens f64
	foundation_accounts_info []FoundationAccountInfo
	locked_tokens_info []LockedTokensInfo
}

struct Balance {
pub:
	amount f64
	asset string
}

struct Account {
pub mut:
	address string
	balances []Balance
	vesting_accounts []VestingAccount
	locked_amounts []LockedAmount
}

struct VestingAccount {
pub mut:
	address string
	vestingscheme string
	balances []Balance
}

struct LockedAmount {
pub mut:
	address string
	locked_until string
	balances []Balance
}

//
// Formatter
//
//
// Workflow
//
fn download(target string, account string, mut r redisclient.Redis) string {
	links := {
		"tft:raw": "https://statsdata.threefoldtoken.com/stellar_stats/api/stats?detailed=true",
		"tfta:raw": "https://statsdata.threefoldtoken.com/stellar_stats/api/stats?detailed=true&tokencode=TFTA",
		"account:raw": "https://statsdata.testnet.threefold.io/stellar_stats/api/account/" + account,
	}

	mut key := target

	if key == "account:raw" {
		key = "account:raw:" + account
	}

	println("[+] downloading: " + links[target])
	text := http.get_text(links[target])

	// cache in redis
	r.set(key, text) or { eprintln(err) }

	return text
}

fn parsef(f string) f64 {
	x := f.replace(",", "")
	return strconv.atof64(x)
}

fn parse(tft Raw_StatsTFT, tfta Raw_StatsTFT) StatsTFT {
	mut final := StatsTFT{}

	final.total_tokens = parsef(tft.total_tokens) + parsef(tfta.total_tokens)
	final.total_accounts = parsef(tft.total_accounts) + parsef(tfta.total_accounts)
	final.total_locked_tokens = parsef(tft.total_locked_tokens) + parsef(tfta.total_locked_tokens)
	final.total_vested_tokens = parsef(tft.total_vested_tokens) + parsef(tfta.total_vested_tokens)
	final.total_liquid_foundation_tokens = parsef(tft.total_liquid_foundation_tokens) + parsef(tfta.total_liquid_foundation_tokens)
	final.total_illiquid_foundation_tokens = parsef(tft.total_illiquid_foundation_tokens) + parsef(tfta.total_illiquid_foundation_tokens)
	final.total_liquid_tokens = parsef(tft.total_liquid_tokens) + parsef(tfta.total_liquid_tokens)

	mut info := map[string]map[string]Wallet
	src := [tft, tfta]

	//
	// FoundationAccountInfo
	//
	for source in src {
		for entry in source.foundation_accounts_info {
			for wal in entry.wallets {
				mut found := info[entry.category][wal.address]

				found.address = wal.address
				found.description = wal.description
				found.liquid = wal.liquid
				found.amount += parsef(wal.amount)

				info[entry.category][wal.address] = found
			}
		}
	}

	for cat, val in info {
		mut accountinfo := FoundationAccountInfo{
			category: cat
		}

		for _, wal in val {
			accountinfo.wallets << wal
		}

		final.foundation_accounts_info << accountinfo
	}

	//
	// LockedTokensInfo
	//
	for source in src {
		for locked in source.locked_tokens_info {
			x := locked.fields()

			final.locked_tokens_info << LockedTokensInfo{
				amount: parsef(x[0]),
				until: x[3] + " " + x[4]
			}
		}
	}

	return final
}

fn parse_balance(bal Raw_Balance) Balance {
	return Balance{
		amount: parsef(bal.amount),
		asset: bal.asset,
	}
}

fn account_info(account Raw_Account) Account {
	mut final := Account{
		address: account.address
	}

	for bal in account.balances {
		final.balances << parse_balance(bal)
	}

	for vest in account.vesting_accounts {
		mut vesting := VestingAccount{
			address: vest.address,
			vestingscheme: vest.vestingscheme,
		}

		for bal in vest.balances {
			vesting.balances << parse_balance(bal)
		}

		final.vesting_accounts << vesting
	}

	for locking in account.locked_amounts {
		mut locked := LockedAmount{
			address: locking.address,
			locked_until: locking.locked_until
		}

		for bal in locking.balances {
			locked.balances << parse_balance(bal)
		}

		final.locked_amounts << locked
	}

	return final
}

pub fn load_tokens() StatsTFT {
	println("[+] connecting to redis")
	mut r := redisclient.connect("127.0.0.1:6379") or { panic(err) }

	println("[+] fetching tokens data from redis")
	rtft := r.get("tft:raw") or { download("tft:raw", "", mut r) }
	rtfta := r.get("tfta:raw") or { download("tfta:raw", "", mut r) }

	tft := json.decode(Raw_StatsTFT, rtft) or {
		eprintln('Failed to decode json')
		return StatsTFT{}
	}

	tfta := json.decode(Raw_StatsTFT, rtfta) or {
		eprintln('Failed to decode json')
		return StatsTFT{}
	}

	merged := parse(tft, tfta)

	return merged
}

pub fn load_account(accid string) Account {
	println("[+] connecting to redis")
	mut r := redisclient.connect("127.0.0.1:6379") or { panic(err) }

	println("[+] fetching account data from redis")
	raccount := r.get("account:raw:" + accid) or { download("account:raw", accid, mut r) }

	account := json.decode(Raw_Account, raccount) or {
		eprintln('Failed to decode json')
		return Account{}
	}

	nicer := account_info(account)

	return nicer
}


/*
fn main() {
	load_tokens()
	load_account()
}
*/
