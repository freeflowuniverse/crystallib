module couchdb

pub struct Doc {
pub mut:
	f1 int
	f2 string
}

fn testsuite_begin() {
	mut cl := get('myinstance', url: '127.0.0.1:5984', username: 'admin', password: 'password')!
	cl.db_create(name: 'mynewdb', admins: ['admin'])!
}

fn testsuite_end() {
	mut cl := get('myinstance', url: '127.0.0.1:5984', username: 'admin', password: 'password')!
	cl.db_delete('mynewdb')!
}

fn test_db() {
	mut cl := get('myinstance', url: '127.0.0.1:5984', username: 'admin', password: 'password')!
	list := cl.db_list()!

	mut my_inst := cl.db_instance('mynewdb')!
	mut mydoc := Doc{
		f1: 1
		f2: 'abc'
	}
	id, mut rev := my_inst.create_document(mydoc)!
	mut ret_doc, mut doc_info := my_inst.get_document[Doc](id)!
	assert doc_info.id == id
	assert doc_info.rev == rev
	assert mydoc == ret_doc

	mydoc.f1 = 2
	_, rev = my_inst.create_or_update_document(id, rev, mydoc)!
	ret_doc, doc_info = my_inst.get_document[Doc](id)!
	assert doc_info.id == id
	assert doc_info.rev == rev
	assert mydoc == ret_doc

	att_data := 'this is my attachment'
	att_name := 'my_attachment'
	_, rev = my_inst.attachment_add(id, rev, att_name, att_data)!
	retrieved_att_data := my_inst.attachment_get(id, att_name)!
	assert att_data == retrieved_att_data

	mut attachments := my_inst.attachment_list(id)!
	assert attachments.len == 1
	assert att_name in attachments.keys()

	_, rev = my_inst.attachment_delete(id, rev, att_name)!
	attachments = my_inst.attachment_list(id)!
	assert attachments.len == 0

	my_inst.delete_document(id, rev)!

	if _, _ := my_inst.get_document[Doc](id) {
		assert false, 'document with id ${id} should have been deleted'
	}
}
