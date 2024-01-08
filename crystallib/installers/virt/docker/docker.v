module docker

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

// install docker will return true if it was already installed
pub fn install() ! {
	console.print_header('package install install docker')
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	base.install()!

	if !osal.done_exists('install_docker') && !osal.cmd_exists('docker') {
		osal.upgrade()!
		osal.package_install('mc,wget,htop,apt-transport-https,ca-certificates,curl,software-properties-common')!
		cmd := '
		rm -f /usr/share/keyrings/docker-archive-keyring.gpg
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		apt update
		apt-cache policy docker-ce
		#systemctl status docker
		'
		osal.execute_silent(cmd)!
		osal.package_install('docker-ce')!
		check()!
		osal.done_set('install_docker', 'OK')!
	}
	console.print_header('docker already done')
}

pub fn check() ! {
	// todo: do a monitoring check to see if it works
	cmd := '
	# Check if docker command exists
	if ! command -v docker &> /dev/null; then
		echo "Error: Docker command-line tool is not installed."
		exit 1
	fi

	# Check if Docker daemon is running
	if ! pgrep -f "dockerd" &> /dev/null; then
		echo "Error: Docker daemon is not running."
		exit 1
	fi

	# Run the hello-world Docker container
	output=$(docker run hello-world 2>&1)

	if [[ "\$output" == *"Hello from Docker!"* ]]; then
		echo "Docker is installed and running properly."
	else
		echo "Error: Failed to run the Docker hello-world container."
		echo "Output: \$output"
		exit 1
	fi

	'
	r := osal.execute_silent(cmd)!
	println(r)
}
