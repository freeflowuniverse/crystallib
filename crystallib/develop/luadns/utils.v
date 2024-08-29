module luadns

fn is_valid_ip(ip string) bool {
	parts := ip.split('.')
	if parts.len != 4 {
		return false
	}
	for part in parts {
		num := part.int()
		if num < 0 || num > 255 {
			return false
		}
	}
	return true
}

fn is_valid_domain(domain string) bool {
	// TODO: implement
	return true
}
