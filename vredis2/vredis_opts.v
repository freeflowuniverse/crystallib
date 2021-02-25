module vredis2

pub fn (mut r Redis) set_opts(key string, value string, opts SetOpts) ? {
	ex := if opts.ex == -4 && opts.px == -4 { '' } else if opts.ex != -4 { ' EX $opts.ex' } else { ' PX $opts.px' }
	nx := if opts.nx == false && opts.xx == false { '' } else if opts.nx == true { ' NX' } else { ' XX' }
	keep_ttl := if opts.keep_ttl == false { '' } else { ' KEEPTTL' }
	r.send_ok(['SET', key, value,"$ex$nx$keep_ttl"])?
}

pub fn (mut r Redis) setex(key string, seconds int, value string) ? {
	return r.set_opts(key, value, SetOpts{
		ex: seconds
	})
}

pub fn (mut r Redis) psetex(key string, millis int, value string) ? {
	return r.set_opts(key, value, SetOpts{
		px: millis
	})
}

pub fn (mut r Redis) setnx(key string, value string) ? {
	r.set_opts(key, value, SetOpts{
		nx: true
	})?
}
