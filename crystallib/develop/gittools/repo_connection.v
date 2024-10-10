module gittools

import os

// Ensure that the repository uses SSH instead of HTTPS in the config file.
// Returns true if the connection method was changed.
fn (repo GitRepo) connection_change(http bool) !bool {
	// Get the repository path
	path2 := repo.path()!

	// Check if the path exists, if not, there's nothing to change
	if !os.exists(path2) {
		return false
	}

	// Build the path to the .git/config file
	pathconfig := os.join_path(path2, '.git', 'config')

	// Verify the config file exists
	if !os.exists(pathconfig) {
		return error("Connection change failed: '${path2}' is not a valid git directory. Missing .git/config file.")
	}

	// Read the content of the config file
	content := os.read_file(pathconfig) or {
		return error('Failed to load config file ${pathconfig}')
	}

	mut result := []string{}
	mut modified := false

	// Process each line in the config file
	for line in content.split_into_lines() {
		if line.contains('url =') {
			// Extract the URL part
			mut url := line.split('=')[1].trim(' ')

			// If the URL already matches the desired scheme, no change needed
			if (url.starts_with('git') && !http) || (url.starts_with('http') && http) {
				return false
			}

			// Get the new URL based on the desired connection type (SSH or HTTP)
			url_new := if http { repo.url_http_get()! } else { repo.url_get()! }

			// Update the line with the new URL
			result << 'url = ' + url_new
			modified = true
		} else {
			// Keep the line unchanged
			result << line
		}
	}

	// If a URL change was made, write the modified config file
	if modified {
		os.write_file(pathconfig, result.join_lines()) or {
			return error('Failed to write updated config to ${pathconfig}')
		}
		return true
	}

	// No changes were made
	return false
}
