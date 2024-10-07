set -ex

cd ~/Downloads

swtpm socket --tpmstate dir=/tmp/mytpm1 --ctrl type=unixio,path=/tmp/swtpm-sock --log level=20 &

qemu-system-x86_64 \
  -enable-kvm \
  -m 8000 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 \
  -boot order=dc \
  -cdrom windows.iso \
  -drive file=windows.qcow2,format=qcow2,if=virtio \
  -vnc :0,password-secret=vnc-password \
  -vga cirrus \
  -net nic,model=virtio \
  -net user \
  -net user,hostfwd=tcp::3389-:3389 \
  -chardev socket,id=chrtpm,path=/tmp/swtpm-sock \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -object secret,id=vnc-password,data=kds007 \
  -monitor stdio

# Block format 'qcow2' does not support the option 'bootindex

#  -drive file=windows.qcow2,format=qcow2,if=virtio \


# it works without this but then we don't have the UEFI
# -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
# -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \


#it should be /usr/share/OVMF/OVMF_CODE_4M.secboot.fd