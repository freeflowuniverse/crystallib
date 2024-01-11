#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.installers.db.redis as redis_installer


//will automatically start redis
redis_installer.new()!