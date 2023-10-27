module openssl

import freeflowuniverse.crystallib.core.pathlib { Path }

pub struct OpenSSL {
	certpath Path
}

[params]
pub struct OpenSSLArgs {
	certpath string = '~/.openssl'
}

pub fn new(args OpenSSLArgs) !OpenSSL {
	if args.certpath.len < 3 {
		return error('need to give certpath and needs to be bigger than 3 chars')
	}
	mut datapath := pathlib.get_dir(path: args.certpath, create: true)!
	mut ossl := OpenSSL{
		certpath: datapath
	}
	return ossl
}
