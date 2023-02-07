module telegram

import dariotarantini.vgram
import freeflowuniverse.baobab.client

pub struct UITelegram{
pub mut:
	baobab client.Client
}

pub fn new() UITelegram {
	return UITelegram{
		baobab: client.new()!
	}
}

/*
needs to schedule new jobs and wait

*/


