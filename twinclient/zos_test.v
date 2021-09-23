import twinclient { init }

const redis_server = 'localhost:6379'

pub fn test_zos() {
	mut twin_dest := 49
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Deploy ZOS workload
	node_id := u32(2) // CHOOSE THE NODE ID YOU WANT.
	hash := '96e3227c5f19f482b0b2fb21074832a1'
	payload := '{"node_id": $node_id, "hash":"$hash", "metadata":"zm dep","description":"zm test","version":0,"twin_id":49,"expiration":1626394539,"workloads":[{"version":0,"name":"zmountiaia","type":"zmount","data":{"size":10737418240},"metadata":"zm","description":"zm test"},{"version":0,"name":"testznetwork","type":"network","data":{"subnet":"10.240.1.0/24","ip_range":"10.240.0.0/16","wireguard_private_key":"SDtQFBHzYTu/c7dt/X1VDZeGmXmE7TD6nQC5tp4wv38=","peers":[{"subnet":"10.240.2.0/24","wireguard_public_key":"cEzVprB7IdpLaWZqYOsCndGJ5MBgv1q1lTFG1B2Czkc=","allowed_ips":["10.240.2.0/24","100.64.240.2/32"],"endpoint":""}],"wireguard_listen_port":7821},"metadata":"zn","description":"zn test"},{"version":0,"name":"testzmachine","type":"zmachine","data":{"flist":"https://hub.grid.tf/tf-official-apps/base:latest.flist","mounts":[{"name":"zmountiaia","mountpoint":"/mydisk"}],"entrypoint":"/sbin/zinit init","network":{"public_ip":"","interfaces":[{"network":"testznetwork","ip":"10.240.1.5"}],"planetary":true},"size":1,"compute_capacity":{"cpu":1,"memory":2147483648},"env":{"SSH_KEY":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com"}},"metadata":"zmachine","description":"zmachine test"}],"signature_requirement":{"requests":[{"required":false,"twin_id":49,"weight":1}],"signatures":[],"weight_required":1}}'
	println('--------- Deploy ZOS Response ---------')
	tw.deploy(payload) or { panic(err) }
}
