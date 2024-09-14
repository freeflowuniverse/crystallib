module net.smtp

fn new_client(config Client) !&Client
    new_client returns a new SMTP client and connects to it
enum BodyType {
	text
	html
}
struct Attachment {
	filename string
	bytes    []u8
	cid      string
}
struct Client {
mut:
	conn     net.TcpConn
	ssl_conn &ssl.SSLConn = unsafe { nil }
	reader   ?&io.BufferedReader
pub:
	server   string
	port     int = 25
	username string
	password string
	from     string
	ssl      bool
	starttls bool
pub mut:
	is_open   bool
	encrypted bool
}
fn (mut c Client) reconnect() !
    reconnect reconnects to the SMTP server if the connection was closed
fn (mut c Client) send(config Mail) !
    send sends an email
fn (mut c Client) quit() !
    quit closes the connection to the server
struct Mail {
pub:
	from        string
	to          string
	cc          string
	bcc         string
	date        time.Time = time.now()
	subject     string
	body_type   BodyType
	body        string
	attachments []Attachment
	boundary    string
}
