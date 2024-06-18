module systemd

import freeflowuniverse.crystallib.osal

pub struct JournalArgs {
	service string // name of service for which logs will be retrieved
	limit int = 100 // number of last log lines to be shown
}

pub fn journalctl(args JournalArgs) !string {
	cmd := 'journalctl --no-pager -n ${args.limit} -u ${name_fix(args.service)}'
	response := osal.execute_silent(cmd) or {
		return err
	}
	return response
}