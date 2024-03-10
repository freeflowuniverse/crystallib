module garage_s3

import os

@[params]
pub struct S3Config {
pub mut:
	name        string = 'default'
	fs_root     string = '/var/data/s3'
	host        string = 'localhost'
	meta_root   string = '/var/data/s3_meta'
	metric_host string = 'localhost'
	metric_port int    = 9100
	port        int    = 8014
	access_key  string
	secret_key  string
}


// configure caddy as default webserver & start
// node, path, domain
// path e.g. /var/www
// domain e.g. www.myserver.com
pub fn start(config S3Config) ! {
	mut config_file := $tmpl('templates/garage.toml')
	install()!
	os.mkdir_all(config.path)!

	// osal.file_write('${config.path}/index.html', default_html)!

	//use screen see dagu to start


	//TODO: do a test use cmd line garage


}

pub fn stop() ! {

}