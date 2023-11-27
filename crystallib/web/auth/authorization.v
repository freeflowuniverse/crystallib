module auth

pub interface IUser {
	id string
}

pub struct AccessRequest {
	accessor    string
	asset_id    string
	access_type AccessType
}

pub struct AccessControlList {
	entries []AccessControlEntry
}

pub struct AccessControlEntry {
	accessor    string // anything to identify the user accessing the asset by
	permissions []AccessType
}

pub enum AccessType {
	read
	write
}

pub fn (mut app Authenticator) authorize(req AccessRequest) bool {
	app.logger.debug('Authorizing access request ${req} \n ${app.access}')
	return app.access[req.asset_id].authorize(req)
}

// pub struct AccessControl {
// 	permissions map[string][]AccessType
// }

pub fn (acl AccessControlList) authorize(req AccessRequest) bool {
	ace := acl.get_entry(req.accessor) or { return false }
	if req.access_type in ace.permissions {
		return true
	}
	return false
}

pub fn (acl AccessControlList) get_entry(accessor string) ?AccessControlEntry {
	aces := acl.entries.filter(it.accessor == accessor)
	if aces.len > 1 {
		panic('Multiple ACEs for same accessor found. This should never happen.')
	}
	if aces.len == 0 {
		return none
	}
	return aces[0]
}
