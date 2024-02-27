module gitea

import freeflowuniverse.crystallib.ui.console
import json

struct SearchReposResponse {
	data []Repo
	ok   bool
}

// Get repositories from Gitea
pub fn (mut client GiteaClient[Config]) search_repos() ![]Repo {
	r := client.connection.get_json(prefix: 'repos/search')!
	decoded := json.decode(SearchReposResponse, r)!
	return decoded.data
}
