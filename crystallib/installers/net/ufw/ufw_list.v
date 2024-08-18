module ufw
import os

fn ufw_status() !UFWData {
	// Run the UFW status command
	result := os.execute('sudo ufw status')
	if result.exit_code != 0 {
		return error('Error running UFW status: ${result.output}')
	}

	// Split the output into lines
	lines := result.output.split_into_lines()

	// Initialize our data structure
	mut ufw_data := UFWData{
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
		rule := parse_rule(line_trimmed)!
		ufw_data.rules << rule
	}

	return ufw_data
}

fn parse_rule(line string) !Rule {
	parts := line.split_any(' \t').filter(it.len > 0)

	if parts.len != 3{
		return error("error in parsing rule of ufw.\n${parts}")
	}

	mut rule := Rule{
		to: parts[0]
		from: parts[parts.len - 1]
	}

	if parts[1].to_lower().contains("allow"){
		rule.allow=true
	}

	// Check for IPv6
	if rule.to.contains('(v6)') || rule.from.contains('(v6)') {
		rule.ipv6 = true
		rule.to = rule.to.replace('(v6)', '').trim_space()
		rule.from = rule.from.replace('(v6)', '').trim_space()
	}

	// Check for protocol
	if rule.to.contains('/') {
		proto := rule.to.split('/')[1]
		rule.to = rule.to.split('/')[0]
		if proto == 'tcp' {
			rule.tcp = true
		}
		if proto == 'udp' {
			rule.udp = true
		}
		rule.to = rule.to.split('/')[0].trim_space()
	}else{
		rule.tcp = true
		rule.udp = true
	}

	// Convert 'Anywhere' to 'any'
	if rule.from.contains('Anywhere') {
		rule.from = 'any'
	}

	return rule
}