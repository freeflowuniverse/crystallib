module taiga
import x.json2
import net.http
import despiegk.crystallib.redisclient
import crypto.md5

struct TaigaConnection {
mut:
	redis redisclient.Redis
	url string
	auth AuthDetail
	cache_timeout int
}

fn init_connection() TaigaConnection {
	return TaigaConnection{
		redis: redisclient.connect('127.0.0.1:6379') or { redisclient.Redis{} }
	}
}

// const conn = init_connection()

struct AuthDetail {
mut:
	auth_token string
	bio string
	email string
	full_name string
	full_name_display string
	gravatar_id string
	id int
	is_active bool
	username string
	uuid string
}

pub fn new(url string, login string, passwd string,cache_timeout int) TaigaConnection {
	// reuse single object
	mut conn := init_connection()
	conn.auth(url,login,passwd) or {panic("Could not connect to $url with $login and passwd:'$passwd'\n$err")}
	conn.cache_timeout = cache_timeout
	return conn
}

fn (mut h TaigaConnection) header() http.Header {
	mut header := http.new_header_from_map(map{
			http.CommonHeader.content_type: "application/json"
			http.CommonHeader.authorization: "Bearer $h.auth.auth_token"
		}
	)
	return header
}

fn (mut h TaigaConnection) cache_key(prefix string,reqdata string) string{
	mut cache_key := ""
	if reqdata == ""{
		cache_key = 'taiga:' + prefix
	}else{
		cache_key = 'taiga:' + prefix + ":" + md5.hexhash(reqdata)
	}
	return cache_key
}

//return empty if no cachgin
// return 'NULL' if cache but text was empty
fn (mut h TaigaConnection) cache_get(prefix string,reqdata string,cache bool) string {
	mut text := ""
	if cache{
		text = h.redis.get(h.cache_key(prefix,reqdata)) or {
			""
		}
	}else{
		return ""
	}
	return text
}

fn (mut h TaigaConnection) cache_set(prefix string,reqdata string, data string, cache bool){
	if cache{
		key := h.cache_key(prefix,reqdata)
		h.redis.set(key, data) or {
			//do nothing redis does not work
			return
		}
		h.redis.expire(key,h.cache_timeout) or {panic("should never get here, if redis worked expire should also work.$err")}
	}
}

//drop the cache for all
//maintain authentication & reconnect
fn (mut h TaigaConnection) cache_drop(){
	//TODO: 
}

//prefix e.g. projects
fn (mut h TaigaConnection) post_json(prefix string, postdata string, cache bool, authenticated bool) ?map[string]json2.Any{
	mut result := h.cache_get(prefix,postdata,cache)
	// Post with auth header
	if result == "" && authenticated{
		mut req := http.new_request(http.Method.post,"$h.url/api/v1/$prefix",postdata)?
		req.header = h.header()
		println(req)
		response := req.do()?
		result = response.text
	} 
	// Post without auth header
	else {
		response:= http.post_json("$h.url/api/v1/$prefix",postdata)?
		result = response.text
	}
	h.cache_set(prefix, postdata, result, cache)
	data_raw := json2.raw_decode(result) ?
	data := data_raw.as_map()
	return data
}	

fn (mut h TaigaConnection) get_json(prefix string, data string, cache bool) ?map[string]json2.Any{
	mut result := h.cache_get(prefix,data,cache)
	if result == "" {
		// println("MISS1")
		mut req := http.new_request(http.Method.get,"$h.url/api/v1/$prefix",data)?
		req.header = h.header()
		res := req.do()?
		result = res.text
	}
	//means empty result from cache
	if result == "NULL" {
		result = ""
	}
	h.cache_set(prefix,data,result, cache)
	data_raw := json2.raw_decode(result) ?
	data2 := data_raw.as_map()
	return data2
}

fn (mut h TaigaConnection) get_json_str(prefix string, data string, cache bool) ?string{
	mut result := h.cache_get(prefix,data,cache)
	if result == "" {
		// println("MISS1")
		mut req := http.new_request(http.Method.get,"$h.url/api/v1/$prefix",data)?
		req.header = h.header()
		res := req.do()?
		result = res.text
	}
	//means empty result from cache
	if result == "NULL" {
		result = ""
	}
	h.cache_set(prefix,data,result, cache)
	return result
}

fn (mut h TaigaConnection) edit_json(prefix string, id int, data string, cache bool) ?map[string]json2.Any{
	mut req := http.new_request(http.Method.get,"$h.url/api/v1/$prefix/$id",data)?
	req.header = h.header()
	res := req.do()?
	result := res.text
	h.cache_set(prefix,data,result, cache)
	data_raw := json2.raw_decode(result) ?
	data2 := data_raw.as_map()
	return data2
}

fn (mut h TaigaConnection) delete(prefix string, id int, cache bool) ?bool{
	mut req := http.new_request(http.Method.delete,"$h.url/api/v1/$prefix/$id", "")?
	req.header = h.header()
	res := req.do()?
	if res.status_code == 204 {
		return true
	} else {
		return false
	}
}

fn (mut h TaigaConnection) auth(url string, login string, passwd string) ? AuthDetail{
	h.url = url
	if ! h.url .starts_with("http"){
		if h.url .contains("http"){
			return error("url needs to start with http or not contain http. $h.url ")
		}
		h.url  = "https://$h.url"
	}

	//https://docs.taiga.io/api.html#object-auth-user-detail
	data:=h.post_json("auth",'{
			"password": "$passwd",
			"type": "normal",
			"username": "$login"
		}',true, false)?

	mut obj := AuthDetail{}
	obj.auth_token = data["auth_token"].str()
	obj.bio = data["bio"].str()
	obj.email = data["email"].str()
	obj.full_name = data["full_name"].str()
	obj.full_name_display = data["full_name_display"].str()
	obj.gravatar_id = data["gravatar_id"].str()
	obj.id = data["id"].int()
	obj.is_active = data["is_active"].bool()
	obj.username = data["username"].str()
	obj.uuid = data["uuid"].str()

	h.auth = obj

	return h
}



// pub fn (mut h TaigaConnection) getex(url string, expire int) ?string {
// 	// println("[+] cache: request url: " + url)



// 	// println("[+] cache hit")
// 	return hit
// }
