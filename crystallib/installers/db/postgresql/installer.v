module postgresql

// import freeflowuniverse.crystallib.osal.tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.docker
import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base

pub fn requirements() ! {
	if !osal.done_exists('postgres_install') {
		host_remove()!
		docker.install()! // make sure docker is installed and working properly
		zinitinstaller.install()!
		osal.package_install('libpq-dev,postgresql-client')!
		osal.done_set('postgres_install', 'OK')!
		console.print_header('postgresql installed')
	} else {
		console.print_header('postgresql already installed')
	}
}

// remove postgresql from the system
pub fn host_remove() ! {
	if !osal.done_exists('postgres_remove') {
		c := '
		#!/bin/bash

		set +e

		# Stop the PostgreSQL service
		sudo systemctl stop postgresql

		# Purge PostgreSQL packages
		sudo apt-get purge -y postgresql* pgdg-keyring

		# Remove all data and configurations
		sudo rm -rf /etc/postgresql/
		sudo rm -rf /etc/postgresql-common/
		sudo rm -rf /var/lib/postgresql/
		sudo userdel -r postgres
		sudo groupdel postgres

		# Remove systemd service files
		sudo rm -f /etc/systemd/system/multi-user.target.wants/postgresql
		sudo rm -f /lib/systemd/system/postgresql.service
		sudo rm -f /lib/systemd/system/postgresql@.service

		# Reload systemd configurations and reset failed systemd entries
		sudo systemctl daemon-reload
		sudo systemctl reset-failed

		echo "PostgreSQL has been removed completely"

		'
		osal.exec(cmd: c)!
		osal.done_set('postgres_remove', 'OK')!
	}
}
