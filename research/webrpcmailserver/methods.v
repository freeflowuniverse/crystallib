module mail

import time

pub fn (mail Mail) close() ! {}

pub struct LoginParams {
	username string
	password string
}

pub struct SelectParams {
	mailbox string
}

pub struct SelectData {}

pub fn (mail Mail) select_(params SelectParams) !SelectData {
	return SelectData{}
}

pub struct CreateParams {
	mailbox string
}

pub fn (mut mail Mail) create(params CreateParams) ! {
	if params.mailbox in mail.mailboxes {
		return error('Mailbox already exists')
	}
	mail.mailboxes[params.mailbox] = Mailbox{
		name: params.mailbox
	}
}

pub fn (mut mail Mail) delete(mailbox string) ! {
	if mailbox !in mail.mailboxes {
		return error("Mailbox doesn't exists")
	}
	mail.mailboxes.delete(mailbox)
}

pub struct RenameParams {
	mailbox  string
	new_name string
}

pub fn (mut mail Mail) rename(params RenameParams) ! {
	if params.new_name in mail.mailboxes {
		return error('Mailbox already exists')
	}
	mut mbox := mail.mailboxes[params.mailbox] or { return error("Mailbox doesn't exist") }
	mbox.name = params.new_name
	mail.mailboxes.delete(params.mailbox)
	mail.mailboxes[params.new_name] = mbox
}

pub fn (mut mail Mail) subscribe(mailbox string) ! {
	if mailbox !in mail.mailboxes {
		return error("Mailbox doesn't exist")
	}
	mail.mailboxes[mailbox].subscribed = true
}

pub fn (mut mail Mail) unsubscribe(mailbox string) ! {
	if mailbox !in mail.mailboxes {
		return error("Mailbox doesn't exist")
	}
	mail.mailboxes[mailbox].subscribed = false
}

pub struct ListOptions {
	patterns []string
}

pub fn (mail Mail) list(options ListOptions) ![]Mailbox {
	return mail.mailboxes.values()
}

pub struct StatusParams {
	mailbox string
	flags   []string
}

pub fn (mail Mail) status(params StatusParams) !string {
	mbox := mail.mailboxes[params.mailbox] or { return error("Mailbox doesn't exist") }
	mut statuses := []string{} // an array of flag statuses
	for flag in params.flags {
		statuses << '${flag} ${mbox.mails.filter(flag in it.flags).len}'
	}
	return statuses.join(' ')
}

pub struct AppendParams {
	mailbox string
	message string
}

pub fn (mut mail Mail) append(params AppendParams) ! {
	if params.mailbox !in mail.mailboxes {
		return error("Mailbox doesn't exists")
	}
	mail.mailboxes[params.mailbox].mails << Email{
		body: params.message
		time: time.now()
	}
}

pub fn (mail Mail) poll(allow_expunge bool) ! {}

pub fn (mail Mail) idle() ! {}
