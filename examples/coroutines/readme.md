
## Temporary limitations (will be fixed asap)

- coroutines.sleep() needs to be used instead of time.sleep()
- coroutines.initialize() needs to be run at the beginning in main()
- no closures
- no .wait()
- dynamic linking, so need to copy the .so file next to the executable: cp /v/thirdparty/photon/photonwrapper.so .
- vfmt will replace “go" with  “spawn”, so don't use it for now 
