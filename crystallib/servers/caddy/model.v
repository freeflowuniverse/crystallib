module caddy

import net.urllib
import freeflowuniverse.crystallib.servers.caddy.security

@[heap]
pub struct CaddyFile {
pub mut:
	apps Apps
	// site_blocks []SiteBlock
	path        string = '/etc/caddy/Caddyfile'
}

// pub struct SiteBlock {
// pub mut:
// 	addresses  []Address
// 	directives []Directive
// }

pub struct Address {
pub mut:
	url urllib.URL
	description string
}

// pub struct Directive {
// pub mut:
// 	name          string
// 	args          []string
// 	matchers      []Matcher
// 	subdirectives []Directive
// }

// pub struct Matcher {
// pub mut:
// 	name string
// 	args []string
// }

struct AdminConfig {
	disabled         bool
	listen           string
	enforce_origin   bool
	origins          []string
	config           ConfigSettings
	identity         IdentityConfig
	remote           RemoteAdmin
}

struct ConfigSettings {
	persist bool
	load    LoadConfig
}

struct LoadConfig {
	// Add appropriate fields for load config
}

struct IdentityConfig {
	identifiers []string
	issuers     []IssuerConfig
}

struct IssuerConfig {
	// Add appropriate fields for issuer config
}

struct RemoteAdmin {
	listen          string
	access_control  []AdminAccess
}

struct AdminAccess {
	public_keys []string
	permissions []AdminPermissions
}

struct AdminPermissions {
	paths   []string
	methods []string
}

struct LoggingConfig {
	sink  SinkConfig
	logs  map[string]CustomLog
}

struct SinkConfig {
	writer WriterConfig
}

struct WriterConfig {
	// Add appropriate fields for writer config
}

struct CustomLog {
	writer    WriterConfig
	encoder   EncoderConfig
	level     string
	sampling  LogSampling
	include   []string
	exclude   []string
}

struct EncoderConfig {
	// Add appropriate fields for encoder config
}

struct LogSampling {
	interval    int
	first       int
	thereafter  int
}

// struct Config {
// 	admin   AdminConfig
// 	logging LoggingConfig
// 	storage StorageConfig
// 	apps    AppsConfig
// }

struct Apps {
mut:
	security security.Security
	http HTTP
}