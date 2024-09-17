
module heroweb

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.webserver.auth.authentication.email as email_authentication
import freeflowuniverse.crystallib.clients.mailclient
import freeflowuniverse.crystallib.ui.console

pub fn (mut db WebDB) play_authentication(mut plbook playbook.PlayBook) !WebDB {
	console.print_stdout(plbook.str())
	mailclient.play(plbook: *plbook)!
    authenticator_actions := plbook.find(filter: 'webdb.configure_authenticator')!
    if authenticator_actions.len > 1 {
        return error('max one authenticator can be configured per webdb')
    }

    mut mail_client := 'default'
    for action in authenticator_actions {
        mail_client = action.params.get('mail_client')!
    }
    db.authenticator = email_authentication.new_stateless_authenticator(
		mail_client: mailclient.get(name: mail_client)!
	)!

	return db
}
