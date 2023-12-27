module gitea
import freeflowuniverse.crystallib.ui.console
import json

// Get repositories from Gitea
pub fn (mut client GiteaClient) get_repositories() ![]RRepository {
	r := client.connection.get_json_list(prefix: 'user/repos')!
	mut res := []RRepository{}
	for i in r {
		// console.print_debug(i)
		if i.trim_space() != '' {
			res << json.decode(RRepository, i)!
		}
	}
	return res
}
