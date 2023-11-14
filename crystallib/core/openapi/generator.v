module openapi
import json
import os
import freeflowuniverse.crystallib.core.pathlib

pub fn generate()! {

	testdata_path := os.dir(@FILE) + '/templates/petstor.json'
	// testdata_path := os.dir(@FILE) + '/templates/qdrant.json'

	mut example_data:=pathlib.get_file(path:testdata_path)!
	json_str:=example_data.read()!

    // Decoding the JSON string into the Openapi struct
    mut api_data := json.decode(Openapi, json_str) or {
        eprintln('Failed to decode JSON: $err')
        return
    }

    // Example usage of the decoded data
    println('OpenAPI version: ${api_data.openapi}')
    println('API title: ${api_data.info.title}')

    // Encoding the Openapi struct back into JSON
    encoded_json := json.encode(api_data)
    println('Encoded JSON: $encoded_json')

	// now the code to generate the rest client needs to follow


}
