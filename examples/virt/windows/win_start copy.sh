set -ex

cd ~/Downloads

#qemu-img create -f qcow2 windows.qcow2 50G

qemu-system-x86_64 \
  -enable-kvm \
  -m 6000 \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 \
  -drive file=windows.iso,media=cdrom \
  -vnc :0,password-secret=vnc-password \
  -vga std \
  -net nic,model=virtio \
  -net user \
  -net user,hostfwd=tcp::3389-:3389 \
  -object secret,id=vnc-password,data=kds007 \
  
#-drive file=windows.qcow2,format=qcow2,if=virtio \
    
#-vga qxl \
# -monitor stdio
# -bios /usr/share/OVMF/OVMF_CODE_4M.fd \

#   -device qxl-vga,vgamem_mb=32 \


#once virtio installed
# -device virtio-vga,virgl=on,max_vram=16384 \
  
# -chardev socket,id=chrtpm,path=/tmp/swtpm-sock \
  # -tpmdev emulator,id=tpm0,chardev=chrtpm \
  # -device tpm-tis,tpmdev=tpm0 \

# -boot order=d \

#-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
  