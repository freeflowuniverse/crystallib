module publishermod

import json
import strconv
import despiegk.crystallib.texttools
import despiegk.crystallib.tokens

struct ChartData {
	label string
	value i64
}

fn thousand(input f64) string {
	x := i64(input).str()
	mut final := ""
	mut idx := 0

	for i := x.len - 1; i >= 0; i -= 1 {
		s := x[i..i + 1]

		if idx % 3 == 0 && idx > 0 {
			final = "," + final
		}

		final = s + final
		idx += 1
	}

	return final
}

// format an addresst link to stellar
fn address_link(target string, display string) string {
	stellar := "https://stellar.expert/explorer/public/account/"
	prefix := target.before(":")
	addr := target.after(":")

	// not a valid address
	if addr.len < 16 {
		return target
	}

	if prefix == target {
		// no prefix found
		return "[" + display + "](" + stellar + addr + ")"
	}

	return "[(" + prefix + ") " + display + "](" + stellar + addr + ")"
}

fn address(a string) string {
	return address_link(a, a)
}

fn address_trunc(a string) string {
	trunc := a[0..12] + "..."
	return address_link(a, trunc)
}

fn macro_tokens_values(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.load_tokens()

	mut id := macro.params.get("id")?

	mut fields := map[string]f64{}
	fields["total-tokens"] = s.total_tokens
	fields["total-locked-tokens"] = s.total_locked_tokens
	fields["total-vested-tokens"] = s.total_vested_tokens
	fields["total-liquid-foundation-tokens"] = s.total_liquid_foundation_tokens
	fields["total-illiquid-foundation-tokens"] = s.total_illiquid_foundation_tokens
	fields["total-liquid-tokens"] = s.total_liquid_tokens
	fields["total-accounts"] = s.total_accounts

	for key, val in fields {
		if id == key {
			state.lines_server << thousand(val)
		}
	}
}

fn macro_tokens_distribution(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.load_tokens()

	mut out := []string{}
	mut data := []ChartData{}

	data << ChartData{label: "Total Locked in Individual Vesting", value: int(s.total_locked_tokens / 1000) }
	data << ChartData{label: "Total Locked in Community Vesting", value: int(s.total_vested_tokens / 1000) }
	data << ChartData{label: "Total Liquid Foundation", value: int(s.total_liquid_foundation_tokens / 1000) }
	data << ChartData{label: "Total Illiquid Foundation", value: int(s.total_illiquid_foundation_tokens / 1000) }
	data << ChartData{label: "Total Liquid Tokens", value: int(s.total_liquid_tokens / 1000) }

	total_tokens := thousand(s.total_tokens)

	out << "```charty"
	out << '{'
	out << '  "title":  "TFT Distribution (Total: $total_tokens)",'
	out << '  "config": {'
	out << '    "type":    "doughnut",'
	out << '    "labels":  true,'
	out << '    "numbers": true'
	out << '  },'
	out << '  "data": '
	out << json.encode(data)
	out << '}'
	out << "```"

	state.lines_server << out
}

fn macro_tokens_locked_table(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.load_tokens()

	mut out := []string{}

	out << "| Status | Amount | Until |"
	out << "| --- | --- | --- |"

	for locked in s.locked_tokens_info {
		amount := i64(locked.amount).str()
		out << "| Locked | $amount | `$locked.until` |"
	}

	state.lines_server << out
}

fn macro_tokens_locked_chart(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.load_tokens()
	mut out := []string{}

	mut total_locked := i64(0)
	for locked in s.locked_tokens_info {
		total_locked += i64(locked.amount)
	}

	mut months := map[string]f64

	for locked in s.locked_tokens_info {
		key := locked.until[0..8]

		mut value := months[key]
		value += locked.amount
		months[key] = value
	}

	mut data := []ChartData{}
	mut remain := total_locked

	for date, value in months {
		amount := i64(value)
		data << ChartData{label: date, value: remain - amount}
		remain -= amount
	}

	out << "```charty"
	out << '{'
	out << '"title":  "Locked Tokens Expiration",'
	out << '"config": {'
	out << '  "type":    "line",'
	out << '  "labels":  true,'
	out << '  "numbers": true'
	out << '},'
	out << '"data": '
	out << json.encode(data)
	out << '}'
	out << "```"

	state.lines_server << out
}


fn macro_tokens_account_info(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	accid := macro.params.get("id")?
	s := tokens.load_account(accid)

	mut out := []string{}

	out << "### Balance"

	out << "| Asset | Balance |"
	out << "| --- | --- |"
	for bal in s.balances {
		balance := strconv.f64_to_str_l(bal.amount)
		addr := address(bal.asset)

		out << "| $addr | $balance |"
	}

	state.lines_server << out
}

fn macro_tokens_account_vesting(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	accid := macro.params.get("id")?
	s := tokens.load_account(accid)

	mut out := []string{}


	for vest in s.vesting_accounts {
		out << "#### Account " + vest.address
		out << "**Scheme:** `$vest.vestingscheme`"
		out << ""

		out << "| Balance Asset | Balance |"
		out << "| --- | --- |"
		for bal in vest.balances {
			balance := strconv.f64_to_str_l(bal.amount)
			out << "| $bal.asset | $balance |"
		}
	}

	state.lines_server << out
}

fn macro_tokens_account_locked(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	accid := macro.params.get("id")?
	s := tokens.load_account(accid)

	mut out := []string{}

	for locked in s.locked_amounts {
		out << "#### Address " + locked.address
		out << "**Locked until:** `$locked.locked_until`"
		out << ""

		out << "| Balance Asset | Balance |"
		out << "| --- | --- |"
		for bal in locked.balances {
			balance := strconv.f64_to_str_l(bal.amount)
			out << "| $bal.asset | $balance |"
		}
	}

	state.lines_server << out
}

fn macro_tokens_current_distribution(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.parse_special(tokens.load_tokens())

	mut out := []string{}

	out << "| Tokens | Distribution | Done |"
	out << "| --- | --- | --- |"

	mut total := f64(0)

	for _, special in s {
		distribution := special.distribution * 100
		done := strconv.f64_to_str_l(special.done / 1000000).before(".")
		total += special.done

		out << "| $special.name | ${distribution}% | ${done} M |"
	}

	total_found := strconv.f64_to_str_l(total / 1000000).before(".")
	out << "| **Total** | **100%** | **${total_found} M** |"

	state.lines_server << out
}

fn macro_tokens_total_distribution(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.parse_special(tokens.load_tokens())

	mut out := []string{}
	mut data := []ChartData{}

	for _, special in s {
		distribution := int(special.distribution * 100)
		data << ChartData{label: special.name, value: distribution }
	}

	out << "```charty"
	out << '{'
	out << '"title":  "Tokens Total (4 Billion) Distribution (percentage)",'
	out << '"config": {'
	out << '  "type":    "doughnut",'
	out << '  "labels":  true,'
	out << '  "numbers": true'
	out << '},'
	out << '"data": '
	out << json.encode(data)
	out << '}'
	out << "```"

	state.lines_server << out
}

fn macro_tokens_special_wallets_table(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	s := tokens.load_tokens()

	mut out := []string{}

	for info in s.foundation_accounts_info {
		category := info.category.title()

		out << ""
		out << "## $category"
		out << ""

		out << "| Address | Description | Balance |"
		out << "| --- | --- | --- |"

		for wallet in info.wallets {
			addr := address_trunc(wallet.address)
			amount := thousand(wallet.amount)
			out << "| $addr | `$wallet.description` | $amount |"
		}
	}

	state.lines_server << out
}



fn macro_tokens(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut tokentype := macro.params.get('type')?

	if tokentype == "value" {
		macro_tokens_values(mut state, mut macro)?
	}

	if tokentype == "distribution" {
		macro_tokens_distribution(mut state, mut macro)?
	}

	if tokentype == "locked-table" {
		macro_tokens_locked_table(mut state, mut macro)?
	}

	if tokentype == "locked-chart" {
		macro_tokens_locked_chart(mut state, mut macro)?
	}

	if tokentype == "account-info" {
		macro_tokens_account_info(mut state, mut macro)?
	}

	if tokentype == "account-vesting" {
		macro_tokens_account_vesting(mut state, mut macro)?
	}

	if tokentype == "account-locked" {
		macro_tokens_account_locked(mut state, mut macro)?
	}

	if tokentype == "current-distribution" {
		macro_tokens_current_distribution(mut state, mut macro)?
	}

	if tokentype == "total-distribution" {
		macro_tokens_total_distribution(mut state, mut macro)?
	}

	if tokentype == "special-wallets-table" {
		macro_tokens_special_wallets_table(mut state, mut macro)?
	}
}
