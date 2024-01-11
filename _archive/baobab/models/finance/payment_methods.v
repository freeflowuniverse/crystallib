module finance

import freeflowuniverse.protocolme.models.backoffice.people

pub enum BlockchainType {
	stellar
	algorand
	tfchain
	ethereum
	smartchain
}

@[heap]
pub struct PaymentMethodDigital {
pub mut:
	name        string // optional //? should this be required to allow easy switching between payment methods
	blockchain  BlockchainType @[required]
	account     string         @[required]
	description string // optional
	preferred   bool
}

// This is redundant but necessary to avoid C error
pub struct PaymentDigitalNewArgs {
pub mut:
	name        string
	blockchain  string @[required]
	account     string @[required]
	description string
	preferred   bool //? Is this false by default?
}

@[heap]
pub struct PaymentMethodIban {
pub mut:
	name        string // optional
	account_num string
	iban        string          @[required]
	swift_code  string          @[required]
	country     &people.Country @[required]
	description string // optional
	preferred   bool
}

pub struct PaymentIbanNewArgs {
pub mut:
	name        string
	account_num string
	iban        string          @[required]
	swift_code  string          @[required]
	country     &people.Country @[required]
	description string
	preferred   bool //? Is this false by default?
}

// TODO: define
pub type PaymentMethod = PaymentMethodDigital | PaymentMethodIban
