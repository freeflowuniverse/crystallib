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

fn macro_tokens_account_info(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	accid := macro.params.get("id")?
	s := tokens.load_account(accid)

	mut out := []string{}

	out << "### Balance"

	out << "| Asset | Balance |"
	out << "| --- | --- |"
	for bal in s.balances {
		balance := strconv.f64_to_str_l(bal.amount)
		out << "| $bal.asset | $balance |"
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

	if tokentype == "account-info" {
		macro_tokens_account_info(mut state, mut macro)?
	}

	if tokentype == "account-vesting" {
		macro_tokens_account_vesting(mut state, mut macro)?
	}

	if tokentype == "account-locked" {
		macro_tokens_account_locked(mut state, mut macro)?
	}
}
