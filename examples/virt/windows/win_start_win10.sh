set -ex

cd ~/Downloads


qemu-system-x86_64 \
  -enable-kvm \
  -m 8000 \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 \
  -drive file=windows.qcow2,format=qcow2 \
  -vnc :0,password-secret=vnc-password \
  -vga qxl \
  -cdrom virtio-win.iso \  
  -net nic \
  -net user,hostfwd=tcp::3389-:3389,hostfwd=tcp::9922-:22 \
  -object secret,id=vnc-password,data=planetfirst007 \
  -monitor stdio

#-drive file=windows.qcow2,format=qcow2,if=virtio \

# -net nic,model=virtio \
# Block format 'qcow2' does not support the option 'bootindex

#  -drive file=windows.qcow2,format=qcow2,if=virtio \


# it works without this but then we don't have the UEFI
# -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
# -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \


#it should be /usr/share/OVMF/OVMF_CODE_4M.secboot.fd