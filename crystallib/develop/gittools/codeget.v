module gittools

// Converts CodeGetFromUrlArgs to GSCodeGetFromUrlArgs with validation
pub fn (self CodeGetFromUrlArgs) to_gs_code_get_args() !GSCodeGetFromUrlArgs {
	if self.url == '' {
		return error('URL is required for ${self}')
	}

	return GSCodeGetFromUrlArgs{
		path:   self.path
		url:    self.url
		branch: self.branch
		tag:    self.tag
		sshkey: self.sshkey
		pull:   self.pull
		reset:  self.reset
		reload: self.reload
	}
}

// Generates a string representation of GSCodeGetFromUrlArgs
pub fn (self GSCodeGetFromUrlArgs) str() string {
	mut msg := 'code get args url: \'${self.url}\''

	if self.path != '' {
		msg = 'code get args: path: \'${self.path}\''
	}
	if self.branch != '' {
		msg += ' branch: \'${self.branch}\''
	}
	if self.tag != '' {
		msg += ' tag: \'${self.tag}\''
	}
	if self.pull {
		msg += ' pull'
	}
	if self.reset {
		msg += ' reset'
	}

	return msg
}
