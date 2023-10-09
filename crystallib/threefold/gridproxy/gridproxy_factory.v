module gridproxy

import freeflowuniverse.crystallib.clients.httpconnection

[heap]
pub struct GridProxyClient {
pub mut:
	http_client httpconnection.HTTPConnection
}

pub enum TFGridNet {
	main
	test
	dev
	qa
}

[heap]
struct GridproxyFactory {
mut:
	instances map[string]&GridProxyClient
}

fn init_factory() GridproxyFactory {
	mut ef := GridproxyFactory{}
	return ef
}

// Singleton creation
const factory = init_factory()

fn factory_get() &GridproxyFactory {
	return &gridproxy.factory
}

fn gridproxy_url_get(net TFGridNet) string {
	return match net {
		.main { 'https://gridproxy.grid.tf' }
		.test { 'https://gridproxy.test.grid.tf' }
		.dev { 'https://gridproxy.dev.grid.tf' }
		.qa { 'https://gridproxy.qa.grid.tf/' }
	}
}

// return which net in string form
fn tfgrid_net_string(net TFGridNet) string {
	return match net {
		.main { 'main' }
		.test { 'test' }
		.dev { 'dev' }
		.qa { 'qa' }
	}
}

// get returns a gridproxy client for the given net.
//
// * `net` (enum): the net to get the gridproxy client for (one of .main, .test, .dev, .qa).
// * `use_redis_cache` (bool): if true, the gridproxy client will use a redis cache and redis should be running on the host. otherwise, the gridproxy client will not use cache.
//
// returns: `&GridProxyClient`.
pub fn get(net TFGridNet, use_redis_cache bool) !&GridProxyClient {
	mut f := factory_get()
	netstr := tfgrid_net_string(net)
	if netstr !in gridproxy.factory.instances {
		url := gridproxy_url_get(net)
		mut httpconn := httpconnection.new(
			name: 'gridproxy_${netstr}'
			url: url
			cache: use_redis_cache
		)!
		// do the settings on the connection
		httpconn.cache.expire_after = 7200 // make the cache timeout 2h
		mut connection := GridProxyClient{
			http_client: httpconn
		}
		f.instances[netstr] = &connection
	}
	return f.instances[netstr] or {
		return error_with_code('http client error: unknow error happened while trying to access the GridProxyClient instance',
			err_grid_client)
	}
}
