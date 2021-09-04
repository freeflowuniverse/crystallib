module installers

// import despiegk.crystallib.publisher_config
import despiegk.crystallib.process

pub fn brew_remove() ? {
    // mut conf := publisher_config.get()

	script := '
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

	#needs to be done with sudo
	rm -rf /usr/local/Frameworks/
	rm -rf /usr/local/Homebrew/
	rm -rf /usr/local/bin/
	rm -rf /usr/local/etc/
	rm -rf /usr/local/go/
	rm -rf /usr/local/include/
	rm -rf /usr/local/lib/
	rm -rf /usr/local/opt/
	rm -rf /usr/local/sbin/
	rm -rf /usr/local/share/
	rm -rf /usr/local/var/
	'

	process.execute_silent(script) ?
}

pub fn brew_install() ? {
	script := '
	echo ... to be done
	exit 1
	'
	process.execute_silent(script) ?
}
