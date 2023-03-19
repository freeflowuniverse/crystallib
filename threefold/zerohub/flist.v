module tfgrid

import net.http
import json
import freeflowuniverse.crystallib.redisclient

pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
}

//structure which represents flist
pub struct Flist{
pub:
	flisturl string // full path to downloadable flist
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
	typ string [json: type]
	target string
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


pub fn (mut cl TFGridClient) flists_get()! []Flist {
	// /api/flist 
	resp := http.get('https://${zhclient.url}/api/flistslist')!
	flists := json.decode(Flist, resp.body)!
	return flists
}


pub fn (mut cl TFGridClient) get_repos(zhclient zerohub.ZeroHubClientArgs)! []Repository {
	// /api/repositories
	resp := http.get('https://${zhclient.url}/api/repositories')!
	println(resp)
	repos := json.decode(Repository, resp.body)!
	return repos
}

pub fn (mut cl TFGridClient) files_get()! []File {
	// /api/fileslist returns a map of file name to its contents
	// 
	return []File{}
}

pub fn (mut cl TFGridClient) get_repo_flists()! RepoInfo {
	// /api/flist/<repository> returns RepoInfo
	return []Flist{}
}	

pub fn (mut cl TFGridClient) get_flist_dump(zhclient zerohub.ZeroHubClientArgs, repo_name string, flist_name string)! FlistContents {
	
	resp := http.get('https://${zhclient.url}/api/flist/${repo_name}/${flist_name}')
	data := json.decode(FlistContents, resp.body)
	return data
}
