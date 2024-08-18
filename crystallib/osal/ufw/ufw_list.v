module ufw
import os

pub fn ufw_status() !UFWStatus {
	// Run the UFW status command
	result := os.execute('sudo ufw status')
	if result.exit_code != 0 {
		return error('Error running UFW status: ${result.output}')
	}

	// Split the output into lines
	lines := result.output.split_into_lines()

	// Initialize our data structure
	mut ufw_data := UFWStatus{
		rules: []
	}
	mut tostart:=false
	// Parse the output
	for line in lines {
		line_trimmed := line.trim_space()
		if line_trimmed.starts_with('Status:') {
			status := line_trimmed.split(':')[1].trim_space()
			if status.to_lower() == "active"{
				ufw_data.active = true
			}
			continue
		}
		if line_trimmed == ''{
			continue
		}
		if line_trimmed.starts_with('--'){
			tostart = true
			continue
		}		
		if tostart{
			rule := parse_rule(line_trimmed)!
			ufw_data.rules << rule
		}
	}

	return ufw_data
}

fn parse_rule(line_ string) !Rule {
	mut line:=line_
	line=line.replace(" (v6)","(v6)")
	parts := line.split_any(' \t').filter(it.len > 0)

	if parts.len != 3{
		return error("error in parsing rule of ufw.\n${parts}")
	}
	mut to:= parts[0]
	mut rule := Rule{		
		from: parts[parts.len - 1]
	}

	if parts[1].to_lower().contains("allow"){
		rule.allow=true
	}

	// Check for IPv6
	if to.contains('(v6)') || rule.from.contains('(v6)') {
		rule.ipv6 = true
		to = to.replace('(v6)', '').trim_space()
		rule.from = rule.from.replace('(v6)', '').trim_space()
	}

	// Check for protocol
	if to.contains('/') {
		proto := to.split('/')[1]
		to = to.split('/')[0]
		if proto == 'tcp' {
			rule.tcp = true
		}
		if proto == 'udp' {
			rule.udp = true
		}
		to = to.split('/')[0].trim_space()
	}else{
		rule.tcp = true
		rule.udp = true
	}

	rule.port = to.int()

	// Convert 'Anywhere' to 'any'
	if rule.from.contains('Anywhere') {
		rule.from = 'any'
	}

	return rule
}