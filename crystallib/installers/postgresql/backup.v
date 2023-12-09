
module postgresql

// import freeflowuniverse.crystallib.osal.tmux
import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.docker
import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base

// // run postgresql as docker compose
// pub fn backup_all() ! {
// 	c:="
// 	export LC_ALL=C.UTF-8
// 	export LANG=C.UTF-8

// 	mkdir -p /data/backup/db


// 	# for db in $(psql -h localhost -p 5432 -U root -q -c \"SELECT datname FROM pg_database WHERE datistemplate = false;\" | grep -v datname | grep -v postgres | awk '/^\s/ { print $1}'); do
// 	for db in $(psql -h localhost -p 5432 -U root -q -c \"SELECT datname FROM pg_database WHERE datistemplate = false and datname != 'postgres' and datname != 'root';\" -t) ; do
// 		echo \"Backing up \${db}\"
// 		pg_dump -h localhost -p 5432 -U root --dbname=\${db} --format=c > \"/data/backup/db/\${db}.bak\"
// 	done
// 	restic backup --tag all --exclude=*.log --exclude=*/logs /data/backup 
// 	restic backup --tag git /data/git_data
// 	"
// }

