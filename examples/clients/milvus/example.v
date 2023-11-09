module main

import log
import freeflowuniverse.crystallib.clients.milvus
import x.json2

fn main() {
	mut logger := &log.Log{
		level: .debug
	}

	do(mut logger) or {
		logger.error('${err}')
		exit(1)
	}
}

fn do(mut logger log.Log) ! {
	client := milvus.Client{
		token: 'user:password'
	}

	// collection_methods(client, mut logger)!
	vector_methods(client, mut logger)!
}

fn collection_methods(client milvus.Client, mut logger log.Log) ! {
	collection_name := 'my_new_collection'
	client.create_collection(
		collection_name: collection_name
		dimension: u16(100)
	) or { return error('failed to create collection: ${err}') }

	desc := client.describe_collection(collection_name: collection_name) or {
		return error('failed to describe collection: ${err}')
	}
	logger.info('collection description: ${desc}')

	list := client.list_collections() or { return error('failed to list collections: ${err}') }
	logger.info('collections list: ${list}')

	client.drop_collection(collection_name: collection_name) or {
		return error('failed to drop collection: ${err}')
	}
}

fn vector_methods(client milvus.Client, mut logger log.Log) ! {
	collection_name := 'my_new_collection3'
	client.create_collection(
		collection_name: collection_name
		dimension: u16(5)
	) or { return error('failed to create collection: ${err}') }

	mut data := []json2.Any{}
	mut obj := map[string]json2.Any{}
	obj['title'] = 'hamdada'
	mut vector := []json2.Any{}
	vector = [0.23254494, 0.01374953, 0.88497432, 0.05292784, 0.02204868] // the number of elements has to match the collection's dimension
	obj['vector'] = vector
	obj['link'] = 'google.com'
	data << obj

	inserted_vectors := client.insert_vector(collection_name: collection_name, data: data) or {
		return error('failed to insert vector: ${err}')
	}
	logger.info('inserted vectors: ${inserted_vectors}')

	search_res := client.search_vector(
		collection_name: collection_name
		filter: 'link in ["google.com"]'
		vector: [f32(0.23254494), 0.01374953, 0.88497432, 0.05292784, 0.02204868]
		output_fields: ['id', 'title', 'link']
	) or { return error('failed to search for vector: ${err}') }
	logger.info('search result : ${search_res}')

	res := search_res as []json2.Any
	mut ids := []string{}
	for vec in res {
		v := vec.as_map()
		id := v['id'].str()
		ids << id
		logger.info('id: ${id}')
		obj['id'] = id
		obj['title'] = 'modified_title'

		upserted_vectors := client.upsert_vector(
			collection_name: collection_name
			data: data
		) or { return error('failed to upsert vector: ${err}') }
		logger.info('upserted vectors: ${upserted_vectors}')
	}

	for id in ids {
		get_vector_res := client.get_vector(
			collection_name: collection_name
			id: milvus.ID(id)
			output_fields: [
				'id',
				'title',
				'link',
			]
		)!
		logger.info('get result: ${get_vector_res}')

		client.delete_vector(collection_name: collection_name, id: milvus.ID(id)) or {
			return error('failed to delete vector: ${err}')
		}
	}
}
