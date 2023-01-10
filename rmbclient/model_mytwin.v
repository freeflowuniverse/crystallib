module rmbclient

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.params { Params }
import time
import os
import json
import rand
import crypto.ed25519 

//the metadata as we need to remember for all other clients
pub struct TwinMetaPub {
pub:
	signingkey		 string     //signing key as used whens signing the payload
	publickey		 string     //nacl publickey	
	twinid			 u32    	//who am i
	rmb_proxy_ips    []string  	//how do we find our way back, if empty list, then is local, are ip addresses
	ipaddr	     	 string     //
	signature		 string     //signature of encoded list of: signignkey, publickey, twinid, rmb_proxy_ips, ipaddr
}


[params]
pub struct MyTwin {
pub:
	privkey		 	 ed25519.PrivateKey
	twinid			 u32    	//who am i
	rmb_proxy_ips    []string  	//how do we find our way back, if empty list, then is local, are ip addresses
	ipaddr	     	 string
}

pub fn (twin MyTwin) dumps() !string{
	data:=json.encode(twin)	
	return data
}

pub fn twinmeta_load(data string)! MyTwin{
	mytwin:=json.decode(MyTwin,data)!
	return mytwin
}


//ulimit