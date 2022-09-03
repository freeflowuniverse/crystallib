module threefoldmacros

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools
import os

enum State {
	start
	content
	end
}

fn macro_code(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut out := []string{}
	mut out2 := []string{}

	url := macro.params.get('url')?

	from := macro.params.get('from') or { '' }
	to := macro.params.get('to') or { '' }

	mut gs := gittools.get()?

	mut repo := gs.repo_get_from_url(url: url)?

	path := repo.path_content_get()

	if path.ends_with('.ts') {
		out2 << '```typescript'
	} else if path.ends_with('.js') {
		out2 << '```javascript'
	} else if path.ends_with('.go') {
		out2 << '```golang'
	} else if path.ends_with('.v') {
		out2 << '```golang'
	} else if path.ends_with('.py') {
		out2 << '```python'
	} else {
		out2 << '```javascript'
	}

	// out2 <<""

	mut state_lines := State.start

	lines := os.read_lines(path) or { return error('COULD NOT FIND PATH: $path') }
	for line in lines {
		if from != '' && !line.contains(from) && state_lines == State.start {
			continue
		}
		state_lines = State.content
		out << line
		if to != '' && line.contains(to) && state_lines == State.content {
			state_lines = State.end
			break
		}
	}

	out2 << texttools.dedent(out.join_lines()).split('\n')

	// out2 <<""
	out2 << '```\n<br>\n'

	state.lines_server << out2
}
