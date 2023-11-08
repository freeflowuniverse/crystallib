module s3

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.zinit as zinitosal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.zinit

// install s3 will return true if it was already installed
pub fn install() ! {
	base.install()!
	zinit.install()!
	println(' - package_install install s3')
	if !osal.done_exists('install_s3') && !osal.cmd_exists('s3') {
		osal.package_install('libssl-dev,pkg-config')!

		path := gittools.code_get(url: 'https://github.com/leesmet/s3-cas', reset: false, pull: true)!
		cmd := '
		set -ex
		cd ${path}
		cargo build --all-features
		cp /root/code/github/leesmet/s3-cas/target/debug/s3-cas /usr/local/bin
		'
		osal.execute_stdout(cmd) or { return error('Cannot install s3.\n${err}') }
		// osal.done_set('install_s3', 'OK')!
	}
}

// --fs-root <fs-root>             [default: .]
// --host <host>                   [default: localhost]
// --meta-root <meta-root>         [default: .]
// --metric-host <metric-host>     [default: localhost]
// --metric-port <metric-port>     [default: 9100]
// --port <port>                   [default: 8014]
// --access-key <access-key>
// --secret-key <secret-key>
pub struct StartArgs {
pub mut:
	fs_root     string = '/var/data/s3'
	host        string = 'localhost'
	meta_root   string = '/var/data/s3_meta'
	metric_host string
	metric_port int
	port        int = 8014
	access_key  string
	secret_key  string
}

// start the s3 server
//```js
// fs_root string = "/var/data/s3"
// host string = "localhost"
// meta_root string = "/var/data/s3_meta"
// metric_host string
// metric_port int //9100
// port int = 8014
// access_key string [required]
// secret_key string
//```
pub fn start(args_ StartArgs) ! {
	mut args := args_
	mut cmd := 's3-cas --fs-root ${args.fs_root} --host ${args.host} --meta-root ${args.meta_root} --port ${args.port}'
	if args.metric_host.len > 0 {
		cmd += ' --metric-host ${args.metric_host}'
	}
	if args.metric_port > 0 {
		cmd += ' --metric-port ${args.metric_port}'
	}
	if args.secret_key == '' {
		args.secret_key = args.access_key
	}
	cmd += ' --access-key ${args.access_key}'
	cmd += ' --secret-key ${args.secret_key}'

	mut z:=zinitosal.new()!
    p:=z.new(
        name:"s3"
        cmd:cmd
    )!	

}
