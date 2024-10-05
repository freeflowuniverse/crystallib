
 mkdir -p cd /tmp/busyb
cd /tmp/busyb
podman export $(podman create busybox) | tar -C /tmp/busyb -xvf -