module vserver

import os
import freeflowuniverse.crystallib.ui.console
// import json
// import maxux.vssh

struct ServerManager {
	root string
}

pub fn new() ServerManager {
	sm := ServerManager{}
	return sm
}

fn (s ServerManager) execute(command string) bool {
	// console.print_debug(command)

	r := os.execute(command)
	// console.print_debug(r)

	return true
}

pub fn (s ServerManager) raid_stop() !bool {
	if !os.exists('/proc/mdstat') {
		return false
	}

	md := os.read_file('/proc/mdstat')!
	lines := md.split_into_lines()

	for line in lines {
		if line.contains('active') {
			dev := line.split(' ')[0]
			console.print_debug('[+] stopping raid device: ${dev}')

			r := os.execute('mdadm --stop /dev/${dev}')
			if r.exit_code != 0 {
				console.print_debug(r.output)
			}
		}
	}

	return true
}

pub fn (s ServerManager) disks_list() ![]string {
	blocks := os.ls('/sys/class/block')!
	mut disks := []string{}

	for block in blocks {
		if os.is_link('/sys/class/block/${block}/device') {
			// discard cdrom
			events := os.read_file('/sys/class/block/${block}/events')!
			if events.contains('eject') {
				continue
			}

			// that should be good
			disks << block
		}
	}

	return disks
}

pub fn (s ServerManager) disk_erase(disk string) bool {
	// make it safe via wipefs
	r := os.execute('wipefs -a /dev/${disk}')
	if r.exit_code != 0 {
		console.print_debug(r.output)
		return false
	}

	return true
}

fn (s ServerManager) disk_partitions(disk string) ![]string {
	mut files := os.ls('/sys/class/block/${disk}')!
	mut parts := []string{}

	files.sort()
	for file in files {
		if file.starts_with(disk) {
			parts << file
		}
	}

	return parts
}

pub fn (s ServerManager) disk_main_layout(disk string) !map[string]string {
	s.execute('parted /dev/${disk} mklabel msdos')
	s.execute('parted -a optimal /dev/${disk} mkpart primary 0% 768MB')
	s.execute('parted -a optimal /dev/${disk} mkpart primary 768MB 100GB')
	s.execute('parted -a optimal /dev/${disk} mkpart primary linux-swap 100GB 104GB')
	s.execute('parted -a optimal /dev/${disk} mkpart primary 104GB 100%')
	s.execute('parted /dev/${disk} set 1 boot on')

	s.execute('partprobe')

	parts := s.disk_partitions(disk)!
	if parts.len < 4 {
		return error("partitions found doesn't match expected map")
	}

	mut diskmap := map[string]string{}
	diskmap['/'] = parts[1]
	diskmap['/boot'] = parts[0]
	diskmap['swap'] = parts[2]
	diskmap['/disk1'] = parts[3]

	boot := '/dev/' + parts[0]
	root := '/dev/' + parts[1]
	swap := '/dev/' + parts[2]
	more := '/dev/' + parts[3]

	console.print_debug('[+] partition map:')
	console.print_debug('[+]   /       -> ${root}  [ext2]')
	console.print_debug('[+]   /boot   -> ${boot}  [ext4]')
	console.print_debug('[+]   [swap]  -> ${swap}  [swap]')
	console.print_debug('[+]   [extra] -> ${more}  [btrfs]')

	console.print_debug('[+] creating boot partition')
	s.execute('mkfs.ext2 ${boot}')

	console.print_debug('[+] creating root partition')
	s.execute('mkfs.ext4 ${root}')

	console.print_debug('[+] creating swap partition')
	s.execute('mkswap ${swap}')

	console.print_debug('[+] creating storage partition')
	s.execute('mkfs.btrfs -f ${more}')

	return diskmap
}

pub fn (s ServerManager) disk_create_btrfs(disk string) !bool {
	console.print_debug('[+] creating btrfs on disk: /dev/${disk}')
	s.execute('mkfs.btrfs -f /dev/${disk}')

	return true
}

pub fn (s ServerManager) nixos_prepare(diskmap map[string]string) !bool {
	// mounting
	// console.print_debug(diskmap)
	root := diskmap['/']
	boot := diskmap['/boot']
	more := diskmap['/disk1']

	// mandatory on the host
	console.print_debug('[+] creating required user, groups and directories')
	s.execute('groupadd -g 30000 nixbld')
	s.execute('useradd -u 30000 -g nixbld -G nixbld nixbld')

	os.mkdir('/nix')!
	os.mkdir('/mnt/nix')!

	console.print_debug('[+] mounting target disks')
	// mounting our extra disk for setup nix store
	s.execute('mount /dev/${more} /nix')
	s.execute('mount /dev/${root} /mnt/nix')

	os.mkdir('/mnt/nix/boot')!
	s.execute('mount /dev/${boot} /mnt/nix/boot')

	return true
}

pub fn (s ServerManager) nixos_install(bootdisk string, sshkey string) !bool {
	console.print_debug('[+] installing nix tools on the host')
	os.execute('curl -L https://nixos.org/nix/install | sh')
	// . /root/.nix-profile/etc/profile.d/nix.sh

	version := '23.11'
	console.print_debug('[+] updating channels, using version: ${version}')
	s.execute('/root/.nix-profile/bin/nix-channel --add https://nixos.org/channels/nixos-${version} nixpkgs')
	s.execute('/root/.nix-profile/bin/nix-channel --update')

	console.print_debug('[+] installing nixos install tools scripts')
	s.execute("/root/.nix-profile/bin/nix-env -f '<nixpkgs>' -iA nixos-install-tools")

	console.print_debug('[+] generating default configuration')
	s.execute('/root/.nix-profile/bin/nixos-generate-config --root /mnt/nix/')

	// /mnt/nix/etc/nixos/configuration.nix

	config := '
{ config, lib, pkgs, ... }:

{

    boot.loader.grub.device = "${bootdisk}";
    time.timeZone = "Europe/Brussels";

    environment.systemPackages = with pkgs; [
        vim
        wget
    ];

    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
        "${sshkey}"
    ];

}
'

	console.print_debug('[+] applying custom modification to configuration')
	os.write_file('/mnt/nix/etc/nixos/threefold.nix', config)!

	original := os.read_file('/mnt/nix/etc/nixos/configuration.nix')!
	updated := original.replace('./hardware-configuration.nix', './hardware-configuration.nix\n      ./threefold.nix')

	os.write_file('/mnt/nix/etc/nixos/configuration.nix', updated)!

	console.print_debug('[+] committing... installing nixos')

	// to specify environment variable set by nix, the easier solution
	// is using a temporary shell script
	script := '
. /root/.nix-profile/etc/profile.d/nix.sh
/root/.nix-profile/bin/nixos-install --no-root-passwd --root /mnt/nix
	'

	os.write_file('/tmp/nix-setup', script)!

	// apply configuration and install stuff
	os.execute('bash /tmp/nix-setup')

	return true
}

pub fn (s ServerManager) nixos_finish() !bool {
	console.print_debug('[+] cleaning up, unmounting filesystem')
	s.execute('umount -R /mnt/nix')
	s.execute('umount -R /nix')

	return true
}
