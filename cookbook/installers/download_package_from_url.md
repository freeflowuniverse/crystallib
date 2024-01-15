
```go
import freeflowuniverse.crystallib.osal

version:='1.21.6'
mut url := ''
	if osal.is_linux_arm() {
		url = 'https://go.dev/dl/go${version}.limux-arm64.tar.gz'
	}else if osal.is_linux_intel() {
		url = 'https://go.dev/dl/go${version}.linux-amd64.tar.gz'
	} else if osal.is_osx_arm() {
		url = 'https://go.dev/dl/go${version}.darwin-arm64.tar.gz'
	} else if osal.is_osx_intel() {
		url = 'https://go.dev/dl/go${version}.darwin-amd64.tar.gz'
	} else {
		return error('unsupported platform')
	}

    //the downloader is cool, it will check the download succeeds and also check the minimum size
	mut dest := osal.download(
		url: url
		minsize_kb: 40000
	)!

	osal.cmd_add(
		cmdname: 'tailwind'
		source: dest.path
	)!

```

see how easily to check platform and then download and add to path