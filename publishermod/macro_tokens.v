module publishermod

import json
import strconv
import despiegk.crystallib.texttools
import despiegk.crystallib.tokens

struct ChartData {
	label string
	value int
}

fn macro_tokens(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut tokentype := macro.params.get('type')?
	mut out := []string{}

	if tokentype == "value" {
		s := tokens.load_tokens()

		mut value := macro.params.get("value")?

		if value == "total-token" {
			// rv := strconv.f64_to_str_l(s.total_tokens)
			rv := int(s.total_tokens).str()
			state.lines_server << rv
		}
	}

	if tokentype == "distribution" {
		s := tokens.load_tokens()

		mut data := []ChartData{}

		data << ChartData{label: "Total Locked in Individual Vesting", value: int(s.total_locked_tokens / 1000) }
		data << ChartData{label: "Total Locked in Community Vesting", value: int(s.total_vested_tokens / 1000) }
		data << ChartData{label: "Total Liquid Foundation", value: int(s.total_liquid_foundation_tokens / 1000) }
		data << ChartData{label: "Total Illiquid Foundation", value: int(s.total_illiquid_foundation_tokens / 1000) }
		data << ChartData{label: "Total Liquid Tokens", value: int(s.total_liquid_tokens / 1000) }

		total_tokens := int(s.total_tokens / 1000)

		out << "```charty"
		out << '{'
		out << '  "title":  "TFT Distribution (Total: $total_tokens K)",'
		out << '  "config": {'
		out << '    "type":    "doughnut",'
		out << '    "labels":  true,'
		out << '    "numbers": true'
		out << '  },'
		out << '  "data": '
		out << json.encode(data)
		out << '}'
		out << "```"

		println(out)
	}

	state.lines_server << out
}
