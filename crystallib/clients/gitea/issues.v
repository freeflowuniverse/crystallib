module gitea

import json

// Get repositories from Gitea
pub fn (mut client GiteaClient) get_issues(owner string, repo string) ![]RIssue {
	r := client.connection.get_json_list(prefix:"repos/${owner}/${repo}/issues")!
	mut res := []RIssue{}
	for i in r{
		println(i)
		if i.trim_space()!=""{
			res<< json.decode(RIssue, i)!
		}
	}
    return res
}
