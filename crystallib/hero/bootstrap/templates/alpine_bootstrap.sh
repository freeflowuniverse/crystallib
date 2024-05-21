#!/bin/bash

echo "[+] cleaning previous instance of qemu"

killall qemu-system-x86_64

while pidof qemu-system-x86_64; do
    sleep 0.1
done

killall qemu-system-aarch64

while pidof qemu-system-aarch64; do
    sleep 0.1
done

set -ex


# Path to your ISO file
# ISO_PATH="/var/vm/alpine-standard-3.19.1-x86_64.iso"
ISO_PATH="/var/vm/alpine-virt-3.19.1-aarch64.iso"

SHARED_DIR="/tmp/shared"
TAG="host"
HDD_PATH="/var/vm/vm_alpine_arm.qcow2"
UEFI_CODE="/tmp/uefi_code.fd"
UEFI_VARS="/tmp/uefi_vars.fd"




# Check if the ISO file exists
if [ ! -f "$ISO_PATH" ]; then
    echo "ISO file not found: $ISO_PATH"
    exit 1
fi

rm -f $HDD_PATH
if [ ! -f "$HDD_PATH" ]; then
    qemu-img create -f qcow2 $HDD_PATH 10G
fi

if [ ! -f "$UEFI_CODE" ]; then
    cd /tmp
    wget https://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/5181/QEMU-AARCH64/RELEASE_GCC/QEMU_EFI.img.gz
    rm -f QEMU_EFI.img
    gunzip QEMU_EFI.img.gz
    cp QEMU_EFI.img $UEFI_CODE
    #echo "UEFI_CODE file not found: $UEFI_CODE"
    #exit 1
fi

#rm -f $UEFI_VARS
if [ ! -f "$UEFI_VARS" ]; then
    qemu-img create -f qcow2 $UEFI_VARS 64M
fi

rm -f /tmp/alpine.in /tmp/alpine.out
mkfifo /tmp/alpine.in /tmp/alpine.out

echo "[+] starting virtual machine"
qemu-system-aarch64 \
    -machine virt,gic-version=max \
    -cpu max  \
    -drive if=pflash,format=raw,readonly=on,file=$UEFI_CODE \
    -drive if=pflash,file=$UEFI_VARS \
    -m 1024 \
    -cdrom "$ISO_PATH" \
    -drive file="$HDD_PATH",index=0,media=disk,format=qcow2 \
    -boot c \
    -smp cores=2,maxcpus=2 \
    -net nic \
    -net user,hostfwd=tcp::2225-:22 \
    -qmp unix:/tmp/qmp-sock,server,nowait \
    -serial pipe:/tmp/alpine \
    -daemonize

echo "[+] virtual machine started, waiting for console"

set +ex
exec 3<> /tmp/alpine.out

#
# FIXME: automate that in vlang, this is a poc
#
hname="debug-alpine.vm"

while true; do
    read -t 0.1 -u 3 line

    if [ $? -gt 0 -a $? -lt 128 ]; then
        echo "[-] read failed: $?"
        exit 1
    fi

    if [ ${#line} -eq 0 ]; then
        continue
    fi

   #echo "${#line}"
    echo "${line}"

    if [[ ${line} == *"localhost login:"* ]]; then
        echo "[+] authenticating root user"
        echo "root" > /tmp/alpine.in
    fi

    if [[ ${line} == *"localhost:~#"* ]]; then
        echo "[+] running automated setup-alpine process"
        echo "setup-alpine" > /tmp/alpine.in
    fi

    if [[ ${line} == *" [localhost]" ]]; then
        echo "[+] define hostname: $hname"
        echo $hname > /tmp/alpine.in
    fi

    if [[ ${line} == *" [eth0]"* ]]; then
        echo "[+] configuring default interface eth0"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *" [dhcp]"* ]]; then
        echo "[+] configuring eth0 to uses dhcp"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *"manual network configuration? (y/n) [n]"* ]]; then
        echo > /tmp/alpine.in
        echo "[+] waiting for network connectivity"
    fi

    if [[ ${line} == *"New password:"* ]]; then
        echo "[+] setting up root password (root)"
        echo "root" > /tmp/alpine.in
    fi

    if [[ ${line} == *"Retype password:"* ]]; then
        echo "root" > /tmp/alpine.in
    fi

    if [[ ${line} == *"Which NTP client to run"* ]]; then
        echo "[+] default ntp server"
        echo "busybox" > /tmp/alpine.in
    fi

    if [[ ${line} == *"are you in? [UTC]"* ]]; then
        echo "[+] keeping default utc timezone for now"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *"HTTP/FTP proxy URL?"* ]] && [[ ${line} == *" [none]"* ]]; then
        echo "[+] skipping proxy configuration"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *"Enter mirror number or URL: [1]"* ]]; then
        echo "[+] finding and using the fastest mirror"
        echo "http://dl-cdn.alpinelinux.org/alpine/" > /tmp/alpine.in
    fi

    if [[ ${line} == *"Setup a user?"* ]] && [[ ${line} == *" [no]"* ]]; then
        echo "[+] skipping additionnal user creation process"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *" [openssh]"* ]]; then
        echo "[+] installing openssh server"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *" [prohibit-password]"* ]]; then
        echo "[+] authorizing root login with password"
        echo "yes" > /tmp/alpine.in
    fi

    if [[ ${line} == *"Enter ssh key"* ]] && [[ ${line} == *" [none]"* ]]; then
        echo "[+] skipping ssh key for now"
        echo > /tmp/alpine.in
    fi

    if [[ ${line} == *"Which disk"* ]] && [[ ${line} == *" [none]"* ]]; then
        echo "[+] configuring root disk: vda"
        echo "vdb" > /tmp/alpine.in
    fi

    if [[ ${line} == *"How would you like to use it?"* ]] && [[ ${line} == *" [?]"* ]]; then
        echo "sys" > /tmp/alpine.in
    fi

    if [[ ${line} == *"and continue? (y/n) [n]"* ]]; then
        echo "[+] cleaning up disks and installing operating system"
        echo "y" > /tmp/alpine.in
    fi

    if [[ ${line} == *"Installation is complete."* ]]; then
        echo "[+] setup completed, rebooting virtual machine..."
        echo "reboot" > /tmp/alpine.in
    fi

    if [[ ${line} == *"${hname} login:"* ]]; then
        echo "[+] ===================================================================="
        echo "[+] virtual machine configured, up and running, root password: root"
        echo "[+] you can ssh this machine with the local reverse port:"
        echo "[+]"
        echo "[+]     ssh root@localhost -p 2225"
        echo "[+]"
        break
    fi
done

echo "[+] virtual machine initialized"
