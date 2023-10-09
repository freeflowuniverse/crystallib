module mail

import time

pub struct Mail {
mut:
	mailboxes map[string]Mailbox
}

struct Mailbox {
mut:
	name       string
	mails      []Email
	subscribed bool
}

struct Email {
	time    time.Time
	subject string
	from    EmailAddress
	cc      EmailAddress
	bcc     EmailAddress
	body    string
	flags   []Flag
}

type EmailAddress = string
type Flag = string
