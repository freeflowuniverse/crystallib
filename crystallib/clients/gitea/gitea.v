module gitea

// import os
import freeflowuniverse.crystallib.clients.httpconnection
import os

pub struct GiteaClient {
mut:
	connection &httpconnection.HTTPConnection
}

pub fn new() !GiteaClient {
	mut conn := httpconnection.new(
		name: 'gitea'
		url: 'http://localhost:3000/api/v1'
	)!

	env := os.environ()
	if 'GITEA_TOKEN' !in env {
		return error('need to set `GITEA_TOKEN` environment variable with a valid token')
	}
	key := env['GITEA_TOKEN']
	conn.default_header.add(.authorization, 'Bearer ${key}')
	conn.default_header.add(.content_type, 'application/json')

	return GiteaClient{
		connection: conn
	}
}

// curl -X GET "http://localhost:3000/api/v1/admin/cron" -H "Authorization: token $GITEA_TOKEN
