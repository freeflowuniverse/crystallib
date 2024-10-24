#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import toml
import toml.to
import json
import os
import freeflowuniverse.crystallib.data.encoderhero
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.blockchain.stellar



//make the required accou ts


for x in ["mother","signer1","signer2","dest"] {

	if cl.account_exists(x) {
		println("Account $x exists")
	} else {
		println("Account $x does not exist")
		mut cl:= stellar.new_stellar_client()!
	}	
	if cl.account_funded(x) > 10 {
		println("Account $x exists and is enough funded")
	} else {
		println("Account $x is not funded")
		fundingamount:=cl.account_fund(x)!
		assert fundingamount>0
	}
}

cl.signers_add(name:'mother',pubkeys:["signer1","signer2"]) ! 

//TODO: now check if we can again add signers, even if some already existed

//TODO: now show how we can send money from 

cl.send(name:'mother',dest:'dest',amount:1, asset:'xlm') ! 

cl.sign(... not sure how to sign one bu one, is what our users will have to do) !