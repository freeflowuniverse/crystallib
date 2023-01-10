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

//should never be sent outside of the local machine
//is kept on the local
pub struct TwinMetaPrivate {
pub:
	signingkey		 []u8     	//signing key as used whens signing the payload, is private
	privatekey		 []u8     	//nacl privatekey	
	twinid			 u32    	//who am i
	rmb_proxy_ips    []string  	//how do we find our way back, if empty list, then is local, are ip addresses
	ipaddr	     	 string     //if relevant what is my ipaddr
}


//is the struct as we use it in our V process
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
	mytwin:=json.decode(TwinMetaPub,data)!
	MyTwin
	return mytwin
}


//ulimit