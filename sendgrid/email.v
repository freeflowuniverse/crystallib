module sendgrid

struct Recipiant {
	email string  [required]
	name  ?string
}

struct Attatchment {
	content    string  [required]
	type_      ?string [json: 'type']
	filename   string  [required]
	disposion  ?string
	content_id ?string
}

struct UnsubscribeGroups {
	group_id         i64   [required]
	group_to_display []i64
}

struct BypassListManagement {
	enable ?bool
}

struct BypassBounceManagement {
	enable ?bool
}

struct BypassUnsubscribeManagement {
	enable ?bool
}

struct Footer {
	enable ?bool
	text   ?string
	html   ?string
}

struct SandboxMode {
	enable ?bool
}

struct MailSettings {
	bypass_list_management        ?BypassListManagement
	bypass_bounce_management      ?BypassBounceManagement
	bypass_unsubscribe_management ?BypassUnsubscribeManagement
	footer                        ?Footer
	sandbox_mode                  ?SandboxMode
}

struct ClickTrackingSettings {
	enable      ?bool
	enable_text ?bool
}

struct OpenTrackingSettings {
	enable          ?bool
	subsitution_tag ?string
}

struct SubscriptionTrackingSettings {
	enable          ?bool
	text            ?string
	html            ?string
	subsitution_tag ?string
}

struct GoogleAnalyticsSettings {
	enable      ?bool
	utm_source  ?string
	utm_meduim  ?string
	utm_term    ?string
	utm_content ?string
	utm_campain ?string
}

struct TrackingSettings {
	click_tracking       ?ClickTrackingSettings
	open_tracking        ?OpenTrackingSettings
	subscripion_tracking ?SubscriptionTrackingSettings
	ganalytics           ?GoogleAnalyticsSettings
}

pub struct Email {
pub mut:
	personalizations  []Personalizations [required]
	from              Recipiant          [required]
	subject           string             [required]
	content           []Content          [required]
	reply_to          ?Recipiant
	reply_to_list     ?[]Recipiant
	attatchments      ?[]Attatchment
	template_id       ?string
	headers           ?map[string]string
	categories        ?[]string
	custom_args       ?string
	send_at           ?i64
	batch_id          ?string
	asm_              ?UnsubscribeGroups [json: 'asm']
	ip_pool_name      ?string
	mail_settings     ?MailSettings
	tracking_settings ?TrackingSettings
}

pub fn (mut e Email) add_personalization(personalizations []Personalizations) {
	e.personalizations << personalizations
}

pub fn (mut e Email) add_content(content []Content) {
	e.content << content
}

pub fn (mut e Email) add_headers(headers map[string]string) {
	e.headers or {
		e.headers = map[string]string{}
		map[string]string{}
	}

	for k, v in headers {
		e.headers[k] = v
	}
}

pub fn new_email(to []string, from string, subject string, content string) Email {
	mut recipiants := []Recipiant{}

	for email in to {
		recipiants << Recipiant{
			email: email
		}
	}

	personalization := Personalizations{
		to: recipiants
	}

	return Email{
		personalizations: [personalization]
		from: Recipiant{
			email: from
		}
		subject: subject
		content: [Content{
			value: content
		}]
	}
}
