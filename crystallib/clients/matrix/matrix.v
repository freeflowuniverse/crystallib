module matrix

// import os
import freeflowuniverse.crystallib.clients.httpconnection

pub struct GithubClient {
mut:
	connection &httpconnection.HTTPConnection
}

pub fn new(secret string) !GithubClient {
	mut conn := httpconnection.new(
		name: 'gitea'
		url: 'http://localhost:3000/api/v1'
	)!
	conn.default_header.add(.authorization, 'Bearer ${secret}')

	return GithubClient{
		connection: conn
	}
}

// curl -X GET "http://localhost:3000/api/v1/admin/cron" -H "Authorization: token ????"
