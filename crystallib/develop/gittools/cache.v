module gittools

import freeflowuniverse.crystallib.core.base
import json

// Save repo to redis cache
fn (repo GitRepo) redis_save() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	repo_json := json.encode(repo)
	cache_key := repo.get_cache_key()
	redis.set(cache_key, repo_json)!
}

// Get repo from redis cache
fn (mut repo GitRepo) redis_load() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	cache_key := repo.get_cache_key()
	repo_json := redis.get(cache_key)!
	if repo_json.len > 0 {
		repo = json.decode(GitRepo, repo_json)!
	}
}