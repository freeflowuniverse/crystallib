module zerohub

import net.http
import json
import x.json2
import os

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

// Returns a json array with all repository/flists found
pub fn (mut cl ZeroHubClient) get_flists() ![]string {
	resp := http.get('https://${cl.url}/api/flist')!
	return json.decode([]string, resp.body)!
}

// Returns a json array with all repositories found
pub fn (mut cl ZeroHubClient) get_repos() ![]Repository {
	resp := http.get('https://${cl.url}/api/repositories')!
	return json.decode([]Repository, resp.body)!
}

// Returns a json array with all repositories and files found
pub fn (mut cl ZeroHubClient) get_files() !map[string][]FlistInfo {
	resp := http.get('https://${cl.url}/api/fileslist')!
	return json.decode(map[string][]FlistInfo, resp.body)
}

// Returns a json array of each flist found inside specified repository
pub fn (mut cl ZeroHubClient) get_repo_flists(repo_name string) ![]FlistInfo {
	resp := http.get('https://${cl.url}/api/flist/${repo_name}')!
	return json.decode([]FlistInfo, resp.body)
}

// Returns json object with flist dumps (full file list)
pub fn (mut cl ZeroHubClient) get_flist_dump(repo_name string, flist_name string) !FlistContents {
	resp := http.get('https://${cl.url}/api/flist/${repo_name}/${flist_name}')!
	data := json.decode(FlistContents, resp.body)!
	return data
}

// Returns json object with some basic information about yourself
pub fn (mut cl ZeroHubClient) get_me() !json2.Any {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me'
	}

	resp := req.do()!
	return json2.raw_decode(resp.body)!
}

// Returns json object with flist dumps (full file list)
pub fn (mut cl ZeroHubClient) get_my_flist(flist string) !FlistContents {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/${flist}'
	}

	resp := req.do()!
	data := json.decode(FlistContents, resp.body)!
	return data
}

// Remove specific flist from your repo
pub fn (mut cl ZeroHubClient) remove_my_flist(flist string) !json2.Any {
	req := http.Request{
		method: http.Method.delete
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/${flist}'
	}

	resp := req.do()!
	return json2.raw_decode(resp.body)!
}

// Create a symbolic link `linkname` pointing to `source` on your repo
pub fn (mut cl ZeroHubClient) symlink(source string, linkname string) !string {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/${source}/link/${linkname}'
	}
	resp := req.do()!
	return resp.body
}

// Create a cross-repository symbolic link `linkname` pointing to `repository/sourcename`
pub fn (mut cl ZeroHubClient) cross_symlink(repo string, source string, linkname string) !string {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/${linkname}/crosslink/${repo}/${source}'
	}
	resp := req.do()!
	return resp.body
}

// Rename `source` to `destination`
pub fn (mut cl ZeroHubClient) rename(source string, dest string) !string {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/${source}/rename/${dest}'
	}
	resp := req.do()!
	return resp.body
}

// Copy cross-repository `sourcerepo/sourcefile` to your `[local-repository]/localname`
// This is useful when you want to copy flist from one repository to another one
pub fn (mut cl ZeroHubClient) promote(source_repo string, source_name string, localname string) !string {
	req := http.Request{
		method: http.Method.get
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/promote/${source_repo}/${source_name}/${localname}'
	}
	resp := req.do()!
	return resp.body
}

// converts a docker image to an flist. The resulting conversion will stay on your repository
// 
// Args:
//   - image: the full image name on docker hub `docker_repo/image_name`
pub fn (mut cl ZeroHubClient) convert(image string) !string {
	form := http.PostMultipartFormConfig{
		form: {
			'image': image
		}
		header: cl.header
	}

	resp := http.post_multipart_form('https://${cl.url}/api/flist/me/docker', form)!
	return resp.body
}

// merge multiple flist together
// 
// Args:
//   - flists: list of flists names in form "repo_name/flist_name"
//   - target: name of the output flists stored in your repo
pub fn (mut cl ZeroHubClient) merge_flists(flists []string, target string) !string {
	req := http.Request{
		method: http.Method.post
		header: cl.header
		url: 'https://${cl.url}/api/flist/me/merge/${target}'
		data: json.encode(flists)
	}
	resp := req.do()!
	return resp.body
}

// Uploads a `.flist` file and store it
// Note: the flist is checked and full contents is verified to be found on the backend, if some chunks are missing, the file will be discarded
// 
// Args:
//   - path: the path to your `file.flist`
pub fn (mut cl ZeroHubClient) upload_flist(path string) !os.Result {
	cmd := "curl -X Post -H 'Authorization: Bearer ${cl.token}' -F 'file=@${path}'	https://${cl.url}/api/flist/me/upload-flist"

	res := os.execute(cmd)
	return res
}

// Uploads a `.tar.gz` archive and convert it to an flist
// 
// Args:
//   - path: the path to your `file.tar.gz`

pub fn (mut cl ZeroHubClient) upload_archive(path string) !os.Result {
	cmd := "curl -X Post -H 'Authorization: Bearer ${cl.token}' -F 'file=@${path}'	https://${cl.url}/api/flist/me/upload"

	res := os.execute(cmd)
	return res
}
