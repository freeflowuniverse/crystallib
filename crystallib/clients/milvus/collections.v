module milvus

import json
import net.http

pub struct Collection {
pub:
	collection_name string  [json: 'collectionName'; required] // The name of the collection to create.
	db_name         ?string [json: 'dbName'] // The name of the database.
	description     ?string // The description of the collection
	dimension       u16     [required] // The number of dimensions for the vector field of the collection. For performance-optimized CUs, this value ranges from 1 to 32768. For capacity-optimized and cost-optimized CUs, this value ranges from 32 to 32768. The value ranges from 1 to 32768.
	metric_type     string  [json: 'metricType']   = 'L2' // The distance metric used for the collection. The value defaults to L2.
	primary_field   string  [json: 'primaryField'] = 'id' // The primary key field. The value defaults to id.
	vector_field    string  [json: 'vectorField']  = 'vector' // The vector field. The value defaults to vector.
}

pub fn (c Client) create_collection(collection Collection) ! {
	url := '${c.endpoint}/v1/vector/collections/create'
	body := json.encode(collection)
	mut req := http.new_request(http.Method.post, url, body)
	c.do_request(mut req)!
}

/*
possible errors:
		800		database not found
		1800	user hasn't authenticate
		1801	can only accept json format request
		1802	missing required parameters
		1803	fail to marshal collection schema
*/

pub struct Field {
pub:
	auto_id     bool   [json: 'autoId'] // Whether the primary key automatically increments.
	description string // An optional description of the field.
	name        string // The name of the field.
	primary_key bool   [json: 'primaryKey'] // Whether the field is a primary field.
	type_       bool   [json: 'type']       // The data type of the values in this field.
}

pub struct Index {
pub:
	field_name  string [json: 'fieldName']  // The name of the indexed field.
	index_name  string [json: 'indexName']  // The name of the generated index files.
	metric_type string [json: 'metricType'] // The metric type used in the index process.
}

pub struct CollectionDescription {
pub:
	collection_name      string  [json: 'collectionName'] // The name of the collection.
	description          string // An optional description of the collection.
	fields               []Field
	indexes              []Index
	load                 string // The load status of the collection. Possible values are unload, loading, and loaded.
	shards_number        u32     [json: 'shardsNum'] // The number of shards in the collection.
	enable_dynamic_field bool    [json: 'enableDynamicField'] // Whether the dynamic JSON feature is enabled for this collection.
}

[params]
pub struct DescribeCollectionArgs {
	collection_name string  [required] // The name of the collection to describe.
	db_name         ?string // The name of the database.
}

pub fn (c Client) describe_collection(args DescribeCollectionArgs) !CollectionDescription {
	mut url := '${c.endpoint}/v1/vector/collections/describe?collectionName=${args.collection_name}'
	if db_name := args.db_name {
		url = '${url}&dbName=${db_name}'
	}

	mut req := http.new_request(http.Method.get, url, '')
	data := c.do_request(mut req)!

	description := json.decode(CollectionDescription, data)!
	return description
}

[params]
pub struct DropCollectionArgs {
	collection_name string  [json: 'collectionName'; required] // The name of the collection to describe.
	db_name         ?string [json: 'dbName'] // The name of the database.
}

pub fn (c Client) drop_collection(args DropCollectionArgs) ! {
	url := '${c.endpoint}/v1/vector/collections/drop'
	body := json.encode(args)

	mut req := http.new_request(http.Method.post, url, body)
	c.do_request(mut req)!
}

pub fn (c Client) list_collections() ![]string {
	url := '${c.endpoint}/v1/vector/collections'

	mut req := http.new_request(http.Method.get, url, '')
	data := c.do_request(mut req)!

	collections := json.decode([]string, data)!
	return collections
}
