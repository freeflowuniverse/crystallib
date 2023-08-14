module docker

fn test_contains_ssh_port(){
	assert contains_ssh_port(["20001:22"])
}