module taigaexports

import json
import net.urllib
import net.http
import time

// TODO: caching

struct Auth {
	username string
	password string
	type_    string [json: 'type'] = 'normal'
}

struct AuthResult {
	auth_token string
}

struct AsyncExportResult {
	export_id string
}

struct SyncExportResult {
	url string
}

[params]
pub struct ExporterParams {
pub mut:
	url        string
	username   string
	password   string
	auth_token string
	// async mode timeouts
	// time to wait between download/decode attempts
	async_wait i64 = 2 // in seconds, defaults to 2 seconds
	// time to wait until all download attempts are failed
	// or the download itself takes too much
	async_timeout i64 = 10 // in minutes, defaults to 10 minutes
}

pub struct Exporter {
	ExporterParams
mut:
	api_version  string = 'v1'
	api_url      string
	project_slug string
}

pub fn new(args ExporterParams) ?&Exporter {
	parsed_url := urllib.parse(args.url)?
	mut path := ''
	if parsed_url.path !in ['', '/'] {
		path = parsed_url.path.trim('/')
	}

	base_url := 'https://$parsed_url.host/$path'.trim('/')

	mut exporter := &Exporter{}
	exporter.url = base_url
	exporter.api_url = '$base_url/api/$exporter.api_version'
	exporter.username = args.username
	exporter.password = args.password

	if args.auth_token.len > 0 {
		exporter.auth_token = args.auth_token
	} else {
		exporter.authenticate()?
	}

	return exporter
}

pub fn new_from_credentials(url string, username string, password string) ?&Exporter {
	return new(
		url: url
		username: username
		password: password
	)
}

pub fn new_from_token(url string, auth_token string) ?&Exporter {
	return new(
		url: url
		auth_token: auth_token
	)
}

// do request and return the full response
pub fn (mut exporter Exporter) do_req(method http.Method, url string, data string, headers map[http.CommonHeader]string) ?http.Response {
	mut req := http.new_request(method, url, data)?
	if headers.len > 0 {
		req.header = http.new_header_from_map(headers)
	}
	return req.do()
}

pub fn (mut exporter Exporter) authenticate() ? {
	mut auth := Auth{
		username: exporter.username
		password: exporter.password
	}

	url := '$exporter.api_url/auth'
	data := json.encode(auth)
	resp := exporter.do_req(http.Method.post, url, data, {
		http.CommonHeader.content_type: 'application/json'
	})?

	if resp.status() == http.Status.ok {
		result := json.decode(AuthResult, resp.text)?
		exporter.auth_token = result.auth_token
	} else {
		return error('autentication failed ($resp.status_code): $resp.text')
	}
}

// do an authenticated request and return the full response
pub fn (mut exporter Exporter) do_auth_req(method http.Method, url string, data string) ?http.Response {
	return exporter.do_req(method, url, data, {
		http.CommonHeader.content_type:  'application/json'
		http.CommonHeader.authorization: 'Bearer $exporter.auth_token'
	})
}

pub fn (mut exporter Exporter) download(url string) ?string {
	resp := exporter.do_req(http.Method.get, url, '', {})?
	if resp.status() == http.Status.ok {
		return resp.text
	}
	return error('could not download $url ($resp.status_code): $resp.text')
}

pub fn (mut exporter Exporter) export_project(id int, project_slug string) ?ProjectExport {
	// request status need to be checked to decode the result accordingly
	// if the taiga client is async, it will return http.Status.accepted, otherwise it will return http.Status.ok
	url := '$exporter.api_url/exporter/$id'
	resp := exporter.do_auth_req(http.Method.get, url, '')?
	if resp.status() == http.Status.ok {
		result := json.decode(SyncExportResult, resp.text)?
		data := exporter.download(result.url)?
		return json.decode(ProjectExport, data)
	}

	ch := chan ProjectExport{}
	exporter.project_slug = project_slug

	if resp.status() == http.Status.accepted {
		// here we get an export id, and try to poll the result
		// we can get partial json if we tried too soon because of the async nature of this operation,
		// and the lack of an api which tells the status of this export from taiga side
		// we will just do download/decode/retry until we get a result

		result := json.decode(AsyncExportResult, resp.text)?
		export_url := '$exporter.url/media/exports/$id/$project_slug-${result.export_id}.json'

		go fn (mut exporter Exporter, url string, download_chan chan ProjectExport) {
			mut attempts := 0
			for {
				attempts += 1
				println('attempt #$attempts to download/decode $url')

				data := exporter.download(url) or {
					print('attempt #$attempts failed with: $err')
					time.sleep(exporter.async_wait * time.second)
					continue
				}

				export := json.decode(ProjectExport, data) or {
					println('attempt #$attempts failed while decoding response')
					time.sleep(exporter.async_wait * time.second)
					continue
				}

				// if we reached here, we might get a data that can be decoded
				// but it's still not the whole data, would get an empty export
				// in this case, just compare the slug
				if export.slug != exporter.project_slug {
					println('attmpet #$attempts failed, got a partial response')
					time.sleep(exporter.async_wait * time.second)
					continue
				}

				download_chan <- export
				break
			}
		}(mut exporter, export_url, ch)

		timeout := exporter.async_timeout * time.minute
		select {
			export := <-ch {
				return export
			}
			timeout {
				return error('timeout waiting for async export for $timeout minutes(s).')
			}
		}
	}

	return error('exporting error ($resp.status_code): $resp.text')
}
