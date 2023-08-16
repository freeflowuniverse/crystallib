module actions

pub struct Actions {
pub mut:
	actions       []Action // should be empty after filter action
	defaultdomain string = 'protocol_me'
	defaultcircle string
	defaultactor  string
}

fn domain_check(c string, block string) ! {
	if c.len == 0 {
		return error('domain not specified\nFor block: ${block}')
	}

	if c.len < 5 {
		return error("domain bad specified (len min 5), found '${c}'.\nFor block: ${block}")
	}
	if c.len > 20 {
		return error("domain bad specified (len max 20), found '${c}'.\nFor block: ${block}")
	}
}

fn book_check(c string, block string) ! {
	if c.len == 0 {
		return error('book not specified\nFor block: ${block}')
	}

	if c.len < 3 {
		return error("book bad specified (len min 3), found '${c}'.\nFor block: ${block}")
	}
	if c.len > 20 {
		return error("book bad specified (len max 20), found '${c}'.\nFor block: ${block}")
	}
}

fn actor_check(c string, block string) ! {
	if c.len == 0 {
		return error('actor not specified\nFor block: ${block}')
	}

	if c.len < 2 {
		return error("actor bad specified (len min 2), found '${c}'.\nFor block: ${block}")
	}
	if c.len > 20 {
		return error("actor bad specified (len max 20), found '${c}'.\nFor block: ${block}")
	}
}

fn name_check(c string, block string) ! {
	if c.len == 0 {
		return error('name not specified\nFor block: ${block}')
	}

	if c.len < 2 {
		return error("name bad specified (len min 2), found '${c}'.\nFor block: ${block}")
	}
	if c.len > 40 {
		return error("name bad specified (len max 40), found '${c}'.\nFor block: ${block}")
	}
}
