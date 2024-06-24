module couchdb

// see http://127.0.0.1:5984/_utils/docs/intro/api.html#documents attachments

// make sure we return as binary

// QUESTION: how should we deal with big documents

// pub struct Attachment {
// pub mut:
// 	content_type   string
// 	data           ?string
// 	digest         string
// 	encoded_length ?u64
// 	encoding       ?string
// 	length         ?u64
// 	revpos         u64
// 	stub           ?bool
// }

pub fn (mut cl CouchDBInstance) attachment_get(doc_id string, attachment_name string) ![]u8 {
	res := cl.connection.send(method: .get, prefix: '${cl.name}/${doc_id}/${attachment_name}')!
	if !res.is_ok() {
		return error('failed to get attachment: (${res.code}) ${res.data}')
	}

	return res.data.bytes()
}

pub fn (mut cl CouchDBInstance) attachment_add(doc_id string, attachment_name string, data []u8) ! {
	res := cl.connection.send(
		method: .put
		prefix: '${cl.name}/${doc_id}/${attachment_name}'
		data: data.str()
	)!
	if !res.is_ok() {
		return error('failed to add attachment: (${res.code}) ${res.data}')
	}
}

pub fn (mut cl CouchDBInstance) attachment_delete(doc_id string, attachment_name string) ! {
	res := cl.connection.send(
		method: .delete
		prefix: '${cl.name}/${doc_id}/${attachment_name}'
	)!
	if !res.is_ok() {
		return error('failed to delete attachment: (${res.code}) ${res.data}')
	}
}

// pub fn (mut cl CouchDBInstance) attachment_list(...)!{

// }
