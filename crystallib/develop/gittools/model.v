module gittools

import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base

// holds the repo's in a memory structure
@[heap]
pub struct GitStructure {
pub mut:
	key      string             // unique key for the git structure is hash of the path or default which is $home/code
	config   GitStructureConfig // configuration settings
	coderoot pathlib.Path
	repos    map[string]&GitRepo // repositories in gitstructure
	loaded   bool                // if true means we walked over all local dir's and loaded from redis cache
}

@[params]
pub struct GitStructureConfig {
pub mut:
	coderoot string // where will the code be checked out, root of code, if not specified comes from context
	light    bool = true // if set then will clone only last history for all branches
	log      bool // means we log the git statements
}

pub struct GitRepo {
pub mut:
	gs            &GitStructure @[skip]
	provider      string // e.g. github.com  (remote all https/git/...), github.com gets replaced to github in short
	account       string // name of the account
	name          string // is the name of the repository
	status_remote GitRepoStatusRemote
	status_local  GitRepoStatusLocal
	config        GitRepoConfig
}

pub struct GitRepoStatusRemote {
pub mut:
	url           string            // url for the remote reference
	latest_commit string            // the latest commit_hash
	branches      map[string]string // branch_name -> commit_hash (ref)
	tags          map[string]string // tag_name -> commit_hash
	last_check    int               // epoch for latest check
}

pub struct GitRepoStatusLocal {
pub mut:
	url        string // url as found on the local disk
	detached   bool   // means we are not on branch we can be e.g. on a tag
	branch     string
	tag        string // if branch is set local then tag cannot be set
	ref        string
	last_check int // epoch for latest check
}

pub struct GitRepoConfig {
pub mut:
	remote_check_period int // seconds we will wait between checks , default on 0, means we check every time
}
