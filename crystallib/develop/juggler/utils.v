module juggler

import time
import json
import net.http

// get repository returns the Repository which belongs to the webhook being evented
pub fn get_event(req http.Request) !Event {
	event := match git_service(req)! {
		.gitea {
			get_gitea_event(req.data)!
		}
		.github {
			get_github_event(req.data)!
		} 
		else {
			return error('Unsupported git service.')
		}
	}
	return GitEvent{...event, time: time.now()}
}

pub fn get_gitea_event(data string) !GitEvent {
	event := json.decode(GiteaEvent, data) or { 
		return error('failed to decode gitea event') 
	}

	name_split := event.repository.full_name.split('/')
	if name_split.len != 2 {
		return error('invalid gitea event format')
	}

	repo := Repository{
		owner: name_split[0]
		name: name_split[1]
		host: event.repository.clone_url.trim_string_left('https://').all_before('/')
		branch: event.ref.all_after_last('/')
	}

	commit := event.commits[0]
	return GitEvent {
		commit: Commit {
			committer: commit.committer.name
			hash: commit.id
			message: commit.message
			time: time.parse_iso8601(commit.timestamp)!
			url:commit.url
		}
		repository: repo
	}
}

pub fn get_github_event(data string) !GitEvent {
	payload := json.decode(GitHubPayload, data) or { 
		return error('failed to decode github event') 
	}

	repo := Repository{
		owner: payload.repository.owner.name
		name: payload.repository.name
		host: 'github.com'
		branch: payload.ref.all_after_last('/')
	}

	return GitEvent {
		repository: repo
		commit: Commit{
			hash: payload.commits[0].id
			url: payload.commits[0].url
			message: payload.commits[0].message
			committer: payload.commits[0].committer.name
			time: time.parse_iso8601(payload.commits[0].timestamp)!
		}
	}
}

pub enum GitService {
	@none
	gitea
	github
}

// git_service returns the git service responsible for a request
pub fn git_service(req http.Request) !GitService {
	user_agent := req.header.get(.user_agent)!
	if user_agent.starts_with('GitHub-Hookshot') {
		return .github
	}
	return .gitea

}