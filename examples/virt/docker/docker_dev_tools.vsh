#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.virt.docker

mut engine := docker.new(prefix: '', localonly: true)!

mut r := engine.recipe_new(name: 'dev_tools', platform: .alpine)

r.add_from(image: 'alpine', tag: 'latest')!

r.add_package(name: 'git,vim')!

r.add_zinit()!

r.add_sshserver()!

r.build(true)!
