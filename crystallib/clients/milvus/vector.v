module milvus

import json
import net.http
import x.json2

type ID = []string | []u32 | string

[params]
pub struct VectorDeleteArgs {
	db_name         ?string [json: 'dbName'] // The name of the database.
	collection_name string  [json: 'collectionName'; required] // The name of the collection to which this operation applies.
	id              ID      [required] // An array of ID/IDs of the entities to be retrieved. This could be a string, list of strings, or list of integers, depending on the id type.
}

pub fn (c Client) delete_vector(args VectorDeleteArgs) ! {
	url := '${c.endpoint}/v1/vector/delete'
	body := json.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	c.do_request(mut req)!
}

[params]
pub struct VectorGetArgs {
	db_name         ?string   [json: 'dbName'] // The name of the database.
	collection_name string    [json: 'collectionName'; required] // The name of the collection to which this operation applies.
	output_fields   ?[]string [json: 'outputFields'] // An array of fields to return along with the search results.
	id              ID        [required] // An array of ID/IDs of the entities to be retrieved. This could be a string, list of strings, or list of integers, depending on the id type.
}

pub fn (c Client) get_vector(args VectorGetArgs) ![]map[string]json2.Any {
	url := '${c.endpoint}/v1/vector/get'
	body := json.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	data := c.do_request(mut req)!

	response := json2.decode[[]map[string]json2.Any](data)!

	return response
}

[params]
pub struct InsertVectorArgs {
	db_name         ?string     [json: 'dbName'] // The name of the database.
	collection_name string      [json: 'collectionName'; required] // The name of the collection to which entities will be inserted.
	data            []json2.Any [required] // An array of entity objects. Note that the keys in an entity object should match the collection schema
}

struct InsertVectorResponse {
	insert_count u32 [json: 'insertCount']
}

pub fn (c Client) insert_vector(args InsertVectorArgs) !u32 {
	url := '${c.endpoint}/v1/vector/insert'
	body := json2.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	data := c.do_request(mut req)!

	response := json.decode(InsertVectorResponse, data)!

	return response.insert_count
}

[params]
pub struct QueryVectorArgs {
	db_name         string   [json: 'dbName'] // The name of the database.
	collection_name string   [json: 'collectionName'; required] // The name of the collection to which this operation applies.
	filter          string   [required] // The filter used to find matches for the search.
	limit           u8 = 100 // The maximum number of entities to return. The sum of this value and that of offset should be less than 16384. The value ranges from 1 to 100.
	offset          u16 // The number of entities to skip in the search results. The sum of this value and that of limit should be less than 16384. The maximum value is 16384.
	output_fields   []string [json: 'outputFields'] // An array of fields to return along with the search results.
}

pub fn (c Client) query_vector(args QueryVectorArgs) ![]map[string]json2.Any {
	url := '${c.endpoint}/v1/vector/query'
	body := json2.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	data := c.do_request(mut req)!

	response := json2.decode[[]map[string]json2.Any](data)!
	return response
}

[params]
pub struct SearchVectorArgs {
	QueryVectorArgs
	params SearchParams
	vector []f32        [required] // The query vector in the form of a list of floating numbers.
}

pub struct SearchParams {
	radius       f64 // The angle where the vector with the least similarity resides.
	range_filter f64 // Used in combination to filter vector field values whose similarity to the query vector falls into a specific range.
}

pub fn (c Client) search_vector(args SearchVectorArgs) ![]map[string]json2.Any {
	url := '${c.endpoint}/v1/vector/search'
	body := json2.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	data := c.do_request(mut req)!

	response := json2.decode[[]map[string]json2.Any](data)!
	return response
}

[params]
pub struct UpsertVectorArgs {
	InsertVectorArgs
}

pub struct UpsertVectorResponse {
	upsert_count u32  [json: 'upsertCount']  // The number of inserted entities.
	upsert_ids   []ID [json: 'upsertIds']   // An array of the IDs of inserted entities.
}

pub fn (c Client) upsert_vector(args UpsertVectorArgs) !UpsertVectorResponse {
	url := '${c.endpoint}/v1/vector/upsert'
	body := json2.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	data := c.do_request(mut req)!

	response := json2.decode[UpsertVectorResponse](data)!
	return response
}
