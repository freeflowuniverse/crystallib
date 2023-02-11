module telegram

import dariotarantini.vgram

pub struct UITelegram{
pub mut:
	bot_chan chan string
	to_user chan string
	waiting_qs map[string]chan string // where string is user_id
	// TODO should there be flows in here?
}

pub fn new() UITelegram {
	return UITelegram{}
}

// TODO separate bnot and UITelegram, there is one UI per flow

pub struct TelegramBot {
	bot vgram.Bot
	to_user chan string
	from_users map[string]chan string // where string is chat_id
}

