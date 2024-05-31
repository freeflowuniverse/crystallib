module griddriver

pub struct Client {
	mnemonic  string
	substrate string
	relay     string
}

pub fn new_client(mnemonics string, substrate string, relay string) Client {
    return Client{
        mnemonic: mnemonics
		substrate: substrate
        relay: relay
    }
}


// TODO: add the rest of griddriver functionalities
