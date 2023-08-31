module github

import json

// get node id of project
pub fn (mut g GithubClient) get_project_node_id(organization string, project_number int) !ProjectResp {
	query := 'query{organization(login: "${organization}") {projectV2(number: ${project_number}){id}}}'
	req := QueryRequest{
		query: query
	}

	data := json.encode(req)
	r := g.graphql_connection.post_json_str(data: data)!
	return json.decode(ProjectResp, r)!
}

// list all projects node ids in an organization, number of returned result depends on count arg
pub fn (mut g GithubClient) list_project_node_ids(organization string, count int) !ProjectResp {
	query := 'query{organization(login: "${organization}") {projectsV2(first: ${count}){nodes {id title}}}}'
	req := QueryRequest{
		query: query
	}

	data := json.encode(req)
	r := g.graphql_connection.post_json_str(data: data)!
	return json.decode(ProjectResp, r)!
}

// list all projects node ids in an organization, number of returned result depends on count arg
pub fn (mut g GithubClient) list_project_items(project_id string, count int) !ProjectInfoResp {
	query := 'query{ node(id: "${project_id}") { ... on ProjectV2 { 
items(first: ${count}) { nodes{ id fieldValues(first: 8) { nodes{ ... on 
ProjectV2ItemFieldTextValue { text field { ... on ProjectV2FieldCommon {  name }}} 
... on ProjectV2ItemFieldDateValue { date field { ... on ProjectV2FieldCommon { name 
} } } ... on ProjectV2ItemFieldSingleSelectValue { name field { ... on 
ProjectV2FieldCommon { name }}}}} content{ ... on DraftIssue { title body } ...on 
Issue { title assignees(first: 10) { nodes{ login }}} ...on PullRequest { title 
assignees(first: 10) { nodes{ login }}}}}}}}}'

	req := QueryRequest{
		query: query
	}

	data := json.encode(req)
	r := g.graphql_connection.post_json_str(data: data)!
	return json.decode(ProjectInfoResp, r)!
} 
