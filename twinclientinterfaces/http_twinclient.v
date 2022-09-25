module twinclientinterfaces
import net.http
import x.json2



pub fn (mut htp HttpTwinClient)init()? HttpTwinClient {
	header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json',
	})
	url := "http://localhost:3000"
	htp.header = header
	htp.url = url
	htp.method = http.Method.post
	return htp
}

pub fn (htp HttpTwinClient) send(functionPath string, args string)? Message{
	function := functionPath.replace('.', '/')
	request := http.Request{
		url: "$htp.url/$function"
		method: htp.method
		header: htp.header,
		data: args,
	}
	resp := request.do()?

	if resp.status_code == 200{
		raw_body := json2.raw_decode(resp.body)?
		body := raw_body.as_map()["result"]?
		response := Message{
			data: body.str()
		}
		return response
	} else {
		return error(resp.status_msg)
	}
}
