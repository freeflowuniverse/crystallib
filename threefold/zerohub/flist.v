module zerohub

import net.http
import json

pub struct Repository {
pub:
	name     string
	official bool
}

pub struct FlistInfo {
pub:
	name     string
	size     string
	updated  i64
	type_    string
	linktime i64
	target   string
}

pub struct FlistContents {
pub:
	regular   i32
	failure   i32
	directory i32
	symlink   string
	fullsize  i64
	content   []File
}

pub struct File {
pub:
	size i64
	path string
}

pub fn (mut cl ZeroHubClient) get_flists() ![]string {
	resp := http.get('https://${cl.url}/api/flist')!
	return json.decode([]string, resp.body)!
}

pub fn (mut cl ZeroHubClient) get_repos() ![]Repository {
	resp := http.get('https://${cl.url}/api/repositories')!
	return json.decode([]Repository, resp.body)!
}

pub fn (mut cl ZeroHubClient) get_files() !map[string][]FlistInfo {
	resp := http.get('https://${cl.url}/api/fileslist')!
	return json.decode(map[string][]FlistInfo, resp.body)
}

pub fn (mut cl ZeroHubClient) get_repo_flists(repo_name string) ![]FlistInfo {
	resp := http.get('https://${cl.url}/api/flist/${repo_name}')!
	return json.decode([]FlistInfo, resp.body)
}

pub fn (mut cl ZeroHubClient) get_flist_dump(repo_name string, flist_name string) !FlistContents {
	resp := http.get('https://${cl.url}/api/flist/${repo_name}/${flist_name}')!
	data := json.decode(FlistContents, resp.body)!
	return data
}
