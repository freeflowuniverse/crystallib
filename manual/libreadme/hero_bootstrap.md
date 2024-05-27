


## troubleshooting

```bash
qemu-system-x86_64 -monitor stdio
#on remote
ssh -L 5901:localhost:5901 root@65.21.132.119
#on new console in remote (osx)
open vnc://localhost:5901
```


