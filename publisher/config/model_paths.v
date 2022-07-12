module config

// paths
// base: ?
// code: where is all code checked out, happens per domain
// codewiki: all wiki's we are working on get a symlink in here
// publish: where do we publish all processed markdown docs
//
// name of the json needs to be config.json
// EXAMPLE JSON:
// {
//     "reset": false,
//     "pull": false,
//     "debug": false,
//     "redis": false,
//     "port": 9998,
//     "paths": {
//         "base": "",
//         "code": "",
//         "codewiki": "",
//         "publish": ""
//     }
// }
pub struct Paths {
pub mut:
	base     string
	code     string
	codewiki string
	publish  string
	var string
}

// get path for wiki site
pub fn (config ConfigRoot) path_publish_wiki_get(name string) ?string {
	config_site := config.site_wiki_get(name)?
	return '$config.publish.paths.publish/wiki_$config_site.name'
}

// get path for website
pub fn (config ConfigRoot) path_publish_web_get(name string) ?string {
	config_web := config.site_web_get(name)?
	return '$config.publish.paths.publish/$config_web.name'
}

pub fn (config ConfigRoot) path_publish_web_get_domain(domain string) ?string {
	for s in config.sites {
		if domain in s.domains {
			return config.path_publish_web_get(s.name)
		}
	}
	return error('Cannot find wiki site with domain: $domain')
}

// NOT WORKING YET
// //return code path for web
// pub fn (mut config ConfigRoot) path_code_web_get(name string)? string {
// 	config_web := config.site_web_get(name)?
// 	return "${config.paths.code}/${config_web.name}"
// }

// NOT WORKING YET
// //return code path for wiki
// pub fn (mut config ConfigRoot) path_code_wiki_get(name string)? string {
// 	config_site := config.site_wiki_get(name)?
// 	return "${config.paths.code}/${config_site.name}"
// }
