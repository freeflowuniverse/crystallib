module syncthing
import x.json2

import freeflowuniverse.crystallib.httpconnection

pub fn (mut a App) query() !{

	mut conn := httpconnection.new(name: 'example', url: 'https://localhost:8384/rest/')!
	// conn.default_header.add(.content_language, 'Content-Language: en-US')
	conn.default_header.set_custom('X-API-Key', 'TR2DcP2zkVgCSFaKykoR74pDZgFZuKM7') !
	res:=conn.get(prefix: 'events')!
	res2:=json2.raw_decode(res)!
	for item in res2.arr(){
		o:=item.as_map()
		// println(o["type"])
		if o["type"].str()=="ItemFinished"{
			println(item.prettify_json_str())
		}
	}

	//https://docs.syncthing.net/v1.23.7/rest/events-get
	//file:///Users/despiegk1/_code/v/vlib/_docs/x.json2.html#Any.as_map

	// println(res)
}