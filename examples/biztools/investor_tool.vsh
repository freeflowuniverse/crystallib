#!/usr/bin/env -S v -n -w -cg -enable-globals run

import freeflowuniverse.crystallib.biz.investortool
import freeflowuniverse.crystallib.core.playbook


mut plbook := playbook.new(path: '${os.home_dir()}/code/git.ourworld.tf/ourworld_holding/investorstool/output')!
mut it := investortool.play(mut plbook)!
it.check()!

