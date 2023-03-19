module tfgrid

import net.http
import json
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.threefold.zerohub

pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
}

pub struct Flist{
pub:
	flisturl string
}

pub struct Repository{
pub:
	name string
	official bool
}

pub struct RepoInfo {
	name string
	flists []FlistInfo
}

pub struct FlistInfo{
pub:
	name string
	size string
	updated i64
	linktime i64
	type_ string 
	target string
}

pub struct FlistData{
pub:
	name string
	updated i64
	type_ string
	size string
}

pub struct FlistContents{
pub:
	regular i32
	failure i32
	directory i32
	symlink string
	fullsize i64
	content []File
}

pub struct File{
pub:
	size i64
	path string
}

pub fn (mut cl TFGridClient) get_flists(zhclient zerohub.ZeroHubClientArgs) ![]string {
	resp := http.get('https://${zhclient.url}/api/flist')!
	return json.body
}

pub fn (mut cl TFGridClient) get_repos(zhclient zerohub.ZeroHubClientArgs)! []Repository {
	resp := http.get('https://${zhclient.url}/api/repositories')!
	repos := []Repository{}
	for repo in resp.body {
		repos << json.decode(Repository, resp.body)!
	}
	return repos
}

pub fn (mut cl TFGridClient) get_files()! map[string][]FlistData {
	resp := http.get('https://${zhclient.url}/api/fileslist')!
	data := map[string][]FlistData{}
	for repo in resp.body {
		// TODOOT: loop over list of flists
		// data << json.decode(Flist, repo.value())!
	}
	return data
}

pub fn (mut cl TFGridClient) get_repo_flists(zhclient zerohub.ZeroHubClientArgs, repo_name string)! []FlistData {
	resp := http.get('https://${zhclient.url}/api/flist/${repo_name}')!
	flists := []FlistData{}
	for flist in resp.body {
		flists << json.decode(FlistData, flist)
	}
	return flists
}	

pub fn (mut cl TFGridClient) get_flist_dump(zhclient zerohub.ZeroHubClientArgs, repo_name string, flist_name string)! FlistContents {
	resp := http.get('https://${zhclient.url}/api/flist/${repo_name}/${flist_name}')!
	data := json.decode(FlistContents, resp.body)!
	return data
}
