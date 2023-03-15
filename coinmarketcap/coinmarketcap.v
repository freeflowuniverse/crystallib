module coinmarketcap

import os
import x.json2
import json
import net.http
import freeflowuniverse.crystallib.redisclient
import crypto.md5

struct CoinMarketConnection {
mut:
	redis  &redisclient.Redis
	url    string
	secret string
	// auth          AuthDetail
	cache_timeout int
}

fn init_connection() CoinMarketConnection {
	mut redis := redisclient.core_get()
	return CoinMarketConnection{
		redis: &redis
	}
}

pub struct CMCNewArgs {
pub mut:
	secret        string
	cache_timeout int
}

struct CoinMarketResult {
	data CoinMarketResultData
}

struct CoinMarketResultData {
	tft CoinMarketResultTFT [json: 'TFT']
}

struct CoinMarketResultTFT {
	quote CoinMarketResultQuote
}

struct CoinMarketResultQuote {
	usd CoinMarketResultUSD [json: 'USD']
}

struct CoinMarketResultUSD {
	price             f64
	percent_change_7d f64
}

pub fn new(args CMCNewArgs) CoinMarketConnection {
	/*
	Create a new taiga client
	Inputs:
		secre: see CoinMarket API key
		cache_timeout: Expire time in seconds for caching

	Output:
		CoinMarketConnection: Client contains taiga auth details, taiga url, redis cleint and cache timeout.
	*/
	mut updated_args := args
	if args.secret == '' && 'CMCKEY' in os.environ() {
		updated_args.secret = os.environ()['CMCKEY']
	}
	if args.cache_timeout == 0 {
		updated_args.cache_timeout = 3600 * 12
	}
	if updated_args.secret == '' {
		panic('CMCKEY needs to be set in env.')
	}
	mut conn := init_connection()
	conn.url = 'https://pro-api.coinmarketcap.com/v1'
	conn.secret = updated_args.secret
	conn.cache_timeout = updated_args.cache_timeout

	if conn.secret == '' {
		panic('secret not specified, use env arg for CMCKEY')
	}

	return conn
}

fn (mut h CoinMarketConnection) header() !http.Header {
	/*
	Create a new header for Content type and Authorization

	Output:
		header: http.Header with the needed headers
	*/
	mut header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json'
	})
	header.add_custom('X-CMC_PRO_API_KEY', h.secret)!
	return header
}

fn cache_key(prefix string, reqdata string) string {
	/*
	Create Cache Key
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.

	Output:
		cache_key: key that will be used in redis
	*/
	mut ckey := ''
	if reqdata == '' {
		ckey = 'coinmarketcap:' + prefix
	} else {
		ckey = 'coinmarketcap:' + prefix + ':' + md5.hexhash(reqdata)
	}
	return ckey
}

fn (mut h CoinMarketConnection) cache_get(prefix string, reqdata string, cache bool) string {
	/*
	Get from Cache
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		cache: Flag to enable caching.
	Output:
		result: If cache ture and no thing stored or cache false will return empty string
	*/
	mut text := ''
	if cache {
		text = h.redis.get(cache_key(prefix, reqdata)) or { '' }
	}
	return text
}

fn (mut h CoinMarketConnection) cache_set(prefix string, reqdata string, data string, cache bool) ! {
	/*
	Set Cache
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		data: Json encoded data.
		cache: Flag to enable caching.
	*/
	if cache {
		key := cache_key(prefix, reqdata)
		h.redis.set(key, data)!
		h.redis.expire(key, h.cache_timeout) or {
			panic('should never get here, if redis worked expire should also work.${err}')
		}
	}
}

fn (mut h CoinMarketConnection) cache_drop() ! {
	/*
	Drop all cache related to taiga
	*/
	all_keys := h.redis.keys('taiga:*')!
	for key in all_keys {
		h.redis.del(key)!
	}
	// TODO:: maintain authentication & reconnect (Need More Info)
}

fn (mut h CoinMarketConnection) get_json(prefix string, data string, query string, cache bool) !map[string]json2.Any {
	/*
	Get Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as Json2.Any map.
	*/
	mut result := h.cache_get(prefix, data, cache)
	if result == '' {
		// println("MISS1")
		mut req := http.Request{}
		if query != '' {
			req = http.new_request(http.Method.get, '${h.url}/${prefix}?${query}', data) or {
				return error("failed to create http request")
			}
		} else {
			req = http.new_request(http.Method.get, '${h.url}/${prefix}', data) or {
				return error("failed to create http request")
			}
		}
		req.header = h.header()!
		res := req.do()!
		result = res.body
	}
	// means empty result from cache
	if result == 'NULL' {
		result = ''
	}
	h.cache_set(prefix, data, result, cache)!
	data_raw := json2.raw_decode(result)!
	data2 := data_raw.as_map()
	return data2
}

fn (mut h CoinMarketConnection) get_json_str(prefix string, data string, query string, cache bool) !string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as string.
	*/
	mut result := h.cache_get(prefix, data, cache)
	if result == '' {
		// println("MISS1")
		mut req := http.Request{}
		if query != '' {
			req = http.new_request(http.Method.get, '${h.url}/${prefix}?${query}', data) or {
				return error("failed to create http request")
			}
		} else {
			req = http.new_request(http.Method.get, '${h.url}/${prefix}', data) or {
				return error("failed to create http request")
			}
		}
		req.header = h.header()!
		res := req.do()!
		result = res.body
	}
	// means empty result from cache
	if result == 'NULL' {
		result = ''
	}
	h.cache_set(prefix, data, result, cache)!
	return result
}

pub fn (mut h CoinMarketConnection) token_price_usd() !f64 {
	prefix := 'cryptocurrency/quotes/latest'
	query := 'symbol=TFT'
	result := h.get_json_str(prefix, '', query, true)!
	r := json.decode(CoinMarketResult, result)!
	price := r.data.tft.quote.usd.price
	per_last_week := r.data.tft.quote.usd.percent_change_7d
	price_avg := price * (100 - per_last_week) / 100

	return price_avg
}
