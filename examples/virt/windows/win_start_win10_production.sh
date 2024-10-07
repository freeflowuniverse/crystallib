set -ex

cd ~/Downloads



qemu-system-x86_64 \
  -enable-kvm \
  -m 8000 \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 \
  -drive file=windows3.qcow2,format=qcow2,if=virtio \
  -drive file=/dev/null,format=raw,if=virtio \
  -vnc :0,password-secret=vnc-password \
  -vga qxl \
  -device virtio-net-pci,netdev=n1 \
  -netdev user,id=n1,hostfwd=tcp::3389-:3389,hostfwd=tcp::9922-:22 \
  -object secret,id=vnc-password,data=planetfirst007 \
  -monitor stdio

# -netdev user,id=n1,hostfwd=tcp::3389-:3389,hostfwd=tcp::9923-:22 \
#  -vga virtio \

# -device virtio-net-pci,netdev=n1 \
#   -netdev user,id=n1,hostfwd=tcp::3389-:3389,hostfwd=tcp::9922-:22 \
  
  # -drive file=windows3.qcow2,format=qcow2,if=virtio \
