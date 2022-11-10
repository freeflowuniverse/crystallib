module digitaltwin

import libsodium
import redisclient
import json
import encoding.base64

const seedlen = 32

struct TestTwins {
mut:
	twins []TestTwin
}

struct TestTwin {
	id     int
	seed   string
	pubkey string
}

// was used to generate the data of the next method, this is for testing
// our code and get 20 twin's prepopulated in the redis
pub fn bootstrap_test_generate() {
	mut pk := libsodium.PrivateKey{
		public_key: []byte{len: libsodium.public_key_size}
		secret_key: []byte{len: libsodium.secret_key_size}
	}

	mut twins := TestTwins{}

	for x in 1 .. 20 {
		mut seed := []byte{len: digitaltwin.seedlen}
		libsodium.randombytes_buf(seed.data, size_t(digitaltwin.seedlen))
		println('[+] generated seed for twin: $x')

		libsodium.crypto_box_seed_keypair(pk.public_key.data, pk.secret_key.data, seed.data)

		tw := TestTwin{
			id: x
			seed: base64.encode(seed)
			pubkey: base64.encode(pk.public_key)
		}

		twins.twins << tw
	}
	// data2 := json.encode(tw)
	data := json.encode_pretty(twins)
	println(data)
}

// put the digital twin info in the redis, this means we will not have to go to the explorer, for tests
pub fn bootstrap_test_populate(mut redis redisclient.Redis) {
	data := '
        {
        "twins":        [{
                        "id":   1,
                        "seed": "KsJIiwGlMnR0EkYgWnaGiNI20m+KrYiryNxEc7JLiIM=",
                        "pubkey":       "umaiq3J4wtGoY+nlm1Zb7Y958k639n6rRWzh2pcSGzg="
                }, {
                        "id":   2,
                        "seed": "beaUPzd149kTn5lBmCjGJS81gE2V7qFk/+0gnsg344w=",
                        "pubkey":       "5M3kx8yxmDE/te8ibfERiLImua9dgGVcYjAoG7k0ri4="
                }, {
                        "id":   3,
                        "seed": "8PeRvXpWnDwrEq+zjN0BA6JiSuzkxKej2nJI1RcMQTU=",
                        "pubkey":       "7A+xyzIv8CTfucmqUbi10ZAufs9nsXEpnyZb0OY6XDU="
                }, {
                        "id":   4,
                        "seed": "jUpkQ8832V2hLTKoz2zEbGpny+yhvOnkx4g+R8sq5N0=",
                        "pubkey":       "LRtoNujg4HFy9/DundZEEEbav0aiW4QezCOppQ3QnX8="
                }, {
                        "id":   5,
                        "seed": "/Ys0pdFOFnMzbAh0Z4DAAuFkXGQaDn68YV+BSc5efYg=",
                        "pubkey":       "toRSXMKjonvB1fXQaaFEa0u21D5BE//L9ZQi7Xr4HRU="
                }, {
                        "id":   6,
                        "seed": "5CqNKo7OEBBizqQHi9RAxYivvQKyJ35XCtYwcF5dFaQ=",
                        "pubkey":       "RlgRSD/3gN0suIXMOT2g5X39oiAMi44XXa9RcsxNjA0="
                }, {
                        "id":   7,
                        "seed": "xVGhPAcHGMDnXTMC3pn2ca1WkVzdAWoSCqxgSQNf69o=",
                        "pubkey":       "Vw8JlMk5F3bm/Lw+cf81Ixc9tm++uTs1SrfhYV7GyQs="
                }, {
                        "id":   8,
                        "seed": "2vmMaVUkTwq8fZY7PTmFDWBrPuBqadvP8h+8o1fK7lo=",
                        "pubkey":       "/Cq3O11R8LuETnakYqR9bg3Yjj/RndVIW/Ay/YFJDik="
                }, {
                        "id":   9,
                        "seed": "6hhZhe88tDsNHlRITdwq5U0es21Yc0gHprH5lBvHm9E=",
                        "pubkey":       "aQmAverEgQ0hOH4eEiOzdjUos+ziqlMeRqBpt2kx3Eo="
                }, {
                        "id":   10,
                        "seed": "3YS0ssOaAZfx9PPOt+pG6f/VlvTau6SIyiEKAwyXevM=",
                        "pubkey":       "9vYPmpK3+BJmUtxmHQPCzxt1tGbRZ7+g5abVhkYX130="
                }, {
                        "id":   11,
                        "seed": "WPuKy4WUfP/WrTpxROpy0uN5TpcCLucmKT8AVEOBgb0=",
                        "pubkey":       "4tACRJNaj9tq19D5tivci5UeeQ5ShGARjMmi5mENABo="
                }, {
                        "id":   12,
                        "seed": "k3CKM6MyDwK774P/y6vxPeF9a8CV8BbkDTUrAfLuFYc=",
                        "pubkey":       "KVIzRKs97NY6oTwX0YAelgznEBz4A/IZDOttZtSRcmo="
                }, {
                        "id":   13,
                        "seed": "INt73yjnJ98pWyCWemqgnfe8VNgfCFuEtGQGJN0RGbY=",
                        "pubkey":       "MgoqoWnAVQAdsn7DJGYl9HhyPRM6kTl6tKmkIfwJ5lc="
                }, {
                        "id":   14,
                        "seed": "Y9N6Pdx0hY5+W3htJK1lNe+VtEMYNqH3w9ZWiObr23Y=",
                        "pubkey":       "mXO+k1xOGaVCGq1Qlj9gOjsFfxY+UcDTur8QoybbDU0="
                }, {
                        "id":   15,
                        "seed": "IeMkqESl/a5AOa+fHtS6Cxm8UtMcpBHsymLguuh7bI8=",
                        "pubkey":       "80sNSGlBJ/qnmJS/Qcn9DxXe7Wr6wD+X87DKbgG2LmQ="
                }, {
                        "id":   16,
                        "seed": "2ClcyFEduNaTP6iVP4hrPOOPYUQJXHrBCpaYTIN5NZs=",
                        "pubkey":       "P2F3yldQQehLYFGxaJpLrl4bUOKMTFweUliyF8B3mQ0="
                }, {
                        "id":   17,
                        "seed": "arpB04U0jwpRAlVH4cU64rdXK8/U7l4rAWiM6Ss1XzQ=",
                        "pubkey":       "VYxOtBCoQfaf7PvTSoEC/fcS+VTombKFASyuFS4cfHg="
                }, {
                        "id":   18,
                        "seed": "iUldEN/+kSLKaMmYt1MJge6cglbV1ngANFU3QRe4kaU=",
                        "pubkey":       "PhtnxtXeSD0CnF4LVZRs1W9fJwS0Q6N8TLemoOnhr1A="
                }, {
                        "id":   19,
                        "seed": "7bJFxJ/GMawhgCHfq0GunVuQ6o2rLPLGjWqs7mJiCnQ=",
                        "pubkey":       "/8DuwLXAItk9LQAkTWPGv66Y+FTWPhQw2Pn14CwYiXw="
                }]
        }
	'
	twins := json.decode(TestTwins, data) or { panic(err) }
	for twin in twins.twins {
		redis.hset('twins', '$twin.id', '::1|$twin.pubkey') or {}
	}
}
