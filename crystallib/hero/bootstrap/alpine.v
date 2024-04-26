module bootstrap

import os
import time
import freeflowuniverse.crystallib.osal

const (
    iso_path = "/var/vm/alpine-standard-3.19.1-x86_64.iso"
    hdd_path = "/var/vm/vm_alpine_automated.qcow2"
    hostname = "debug-alpine.vm"
)

pub struct AlpineLoader{
pub mut:
    alpine_url map[string]string
}

pub struct AlpineLoaderArgs{
pub mut:
    alpine_url map[string]string = {
        "aarch64":"https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/aarch64/alpine-standard-3.19.1-aarch64.iso",
        "x86_64":"https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.1-x86_64.iso",
    }
}


pub fn new_alpine_loader(args AlpineLoaderArgs)AlpineLoader{
    mut al := AlpineLoader{alpine_url:args.alpine_url}
    return al
}

//```
// enum CPUType {
// 	unknown
// 	intel
// 	arm
// 	intel32
// 	arm32
// }
//```
pub struct AlpineLaunchArgs{
pub mut:
    name string = "default"
    hostname string = "herodev"
    cputype osal.CPUType
}


pub fn (mut self AlpineLoader) start(args AlpineLaunchArgs)! {

    mut url:=self.alpine_url["x86_64"]
    if args.cputype == .arm{
        url= self.alpine_url["aarch64"]
    }
    mut dest := osal.download(
        url: url
        minsize_kb: 9000
        expand_dir: '/tmp/alpine'
    )!

    println(dest)


    // Clean up previous QEMU instance
    println("[+] cleaning previous instance of qemu")
    os.execute_opt("killall qemu-system-x86_64")!
    for os.system("pidof qemu-system-x86_64") == 0 {
        time.sleep(100 * time.millisecond)
    }

    // Check if the ISO file exists
    if !os.exists(iso_path) {
        println("ISO file not found: $iso_path")
        return
    }

    // Create HDD image if it doesn't exist
    if !os.exists(hdd_path) {
        os.execute_opt("qemu-img create -f qcow2 $hdd_path 10G")!
    }

    // Start the virtual machine
    println("[+] starting virtual machine")
    os.execute_opt("mkfifo /tmp/alpine.in /tmp/alpine.out")!
    os.execute_opt("qemu-system-x86_64 -m 1024 -cdrom \"$iso_path\" -drive file=\"$hdd_path\",index=0,media=disk,format=qcow2 -boot c -enable-kvm -smp cores=2,maxcpus=2 -net nic -net user,hostfwd=tcp::2225-:22 -serial pipe:/tmp/alpine -qmp unix:/tmp/qmp-sock,server,nowait -display none -daemonize")!

    println("[+] virtual machine started, waiting for console")

    // Interact with the console
    mut console_input := os.open("/tmp/alpine.in") or { panic(err) }
    mut console_output := os.open("/tmp/alpine.out") or { panic(err) }
    defer {
        console_input.close()
        console_output.close()
    }

    for {
        mut line := []u8{len: 1024}
        read_count := console_output.read(mut line) or { break }
        line_str := line[..read_count].bytestr()

        // Handle console output and send input
        if line_str.contains("localhost login:") {
            console_input.writeln("root")!
        } else if line_str.contains("localhost:~#") {
            console_input.writeln("setup-alpine")!
        } else if line_str.contains(" [localhost]") {
            console_input.writeln(hostname)!
        } else if line_str.contains(" [eth0]") {
            console_input.writeln("")!
        } else if line_str.contains(" [dhcp]") {
            console_input.writeln("")!
        } else if line_str.contains("manual network configuration? (y/n) [n]") {
            console_input.writeln("")!
            println("[+] waiting for network connectivity")
        } else if line_str.contains("New password:") {
            console_input.writeln("root")!
        } else if line_str.contains("Retype password:") {
            console_input.writeln("root")!
        } else if line_str.contains("are you in? [UTC]") {
            console_input.writeln("")!
        } else if line_str.contains("HTTP/FTP proxy URL?") && line_str.contains(" [none]") {
            console_input.writeln("")!
        } else if line_str.contains("Enter mirror number or URL: [1]") {
            console_input.writeln("")!
        } else if line_str.contains("Setup a user?") && line_str.contains(" [no]") {
            console_input.writeln("")!
        } else if line_str.contains(" [openssh]") {
            console_input.writeln("")!
        } else if line_str.contains(" [prohibit-password]") {
            console_input.writeln("yes")!
        } else if line_str.contains("Enter ssh key") && line_str.contains(" [none]") {
            console_input.writeln("")!
        } else if line_str.contains("Which disk") && line_str.contains(" [none]") {
            console_input.writeln("sda")!
        } else if line_str.contains("How would you like to use it?") && line_str.contains(" [?]") {
            console_input.writeln("sys")!
        } else if line_str.contains("and continue? (y/n) [n]") {
            console_input.writeln("y")!
        } else if line_str.contains("Installation is complete.") {
            console_input.writeln("reboot")!
        } else if line_str.contains("$hostname login:") {
            println("[+] ====================================================================")
            println("[+] virtual machine configured, up and running, root password: root")
            println("[+] you can ssh this machine with the local reverse port:")
            println("[+]")
            println("[+]     ssh root@localhost -p 2225")
            println("[+]")
            break
        }
    }

    println("[+] virtual machine initialized")
}