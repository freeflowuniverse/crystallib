This example demonstrates building an MDBook using the Hero CLI and 3script with pages from collections in multiple remote destinations.

Before running (this is necessary if you're making changes in one of the repos and rerunning the example):

1. `bash crystallib/cli/hero/compile.sh`
2. `redis-server` make sure redis server is running
3. `redis-cli flushall` to reset cache
4. `sudo rm -r ~/3bot/circles/acircle`

After this, you can run `v run examples/cli/hero/example.vsh` or if you want to use the CLI directly: `hero run -u https://github.com/freeflowuniverse/crystallib/tree/development/examples/cli/hero`
