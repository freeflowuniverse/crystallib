open vnc://37.27.132.46:5900

some info:

https://simgunz.org/posts/2021-12-12-boot-windows-partition-from-linux-kvm/


## to test rdp works

nc -vz 37.27.132.46 3389


## to install virtio drivers

https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

## status

- the windows 10 works and is installed

## to enable ssh

Open Settings:
Press Win + I
Go to Apps > Optional features
Click "Add a feature"
Search for "OpenSSH Server"


```bash
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
Get-Service sshd
ipconfig
```


## how to shrink a disk later

use https://learn.microsoft.com/en-us/sysinternals/downloads/sdelete

then 

qemu-img convert -O qcow2 image.qcow2 image2.qcow2

or with commpression:

qemu-img convert -O qcow2 -c image.qcow2 image2.qcow2