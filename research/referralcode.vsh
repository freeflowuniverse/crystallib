#!/usr/bin/env -S v -w -enable-globals run

//import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
//import freeflowuniverse.crystallib.osal
//import os
import rand
import math

const data_dir = '/tmp/test'

// Get the file path for storing referral codes
fn get_path(referralcode string) !pathlib.Path {	
	return pathlib.get_file(path: '${data_dir}/referralcodes/${referralcode[..3]}', create: true)!
}

// Get a referral code
fn get(referralcode string) !string {
	mut referralspath := get_path(referralcode)!
	mut lines_ := referralspath.read()!
	mut lines := lines_.split_into_lines() 
	mut userid := ''
	for line in lines {
		parts := line.split(':')
		if parts.len == 2 && parts[0] == referralcode {
			userid = parts[1]
			break
		}
	}
	return userid
}

// Set a new referral code
fn set(referralcode string, userid string) ! {
	mut referralspath := get_path(referralcode)!
	mut lines_ := referralspath.read()!
	mut lines := lines_.split_into_lines() 
	mut found := false
	for mut line in lines{
		parts := line.split(':')
		if parts.len == 2 && parts[0] == referralcode {
			line = '${referralcode}:${userid}'
			found = true
			break
		}
	}
	if !found {
		lines << '${referralcode}:${userid}'
	}
	lines.sort()
	referralspath.write(lines.join('\n'))!
}

// Delete a referral code
fn delete(referralcode string) ! {
	mut referralspath := get_path(referralcode)!
	mut lines_ := referralspath.read()!
	mut lines := lines_.split_into_lines() 
	mut new_lines := []string{}
	for line in lines {
		parts := line.split(':')
		if parts.len != 2 || parts[0] != referralcode {
			new_lines << line
		}
	}
	referralspath.write(lines.join('\n'))!
}

// Check if a referral code exists
fn exists(referralcode string) !bool {
	mut referralspath := get_path(referralcode)!
	mut lines_ := referralspath.read()!
	mut lines := lines_.split_into_lines() 
	for line in lines {
		parts := line.split(':')
		if parts.len == 2 && parts[0] == referralcode {
			return true
		}
	}
	return false
}

fn referral_code_get_random() !string {
	nr := rand.int_in_range(1, 100000000)!
	return referral_code_get(nr)!
}

fn referral_code_get(nr int) !string {
	// comes from sid, idea is to make our 0...z id, out of int we pass
	mut completed := false
	mut remaining := int(nr)
	mut decimals := []f64{}
	mut count := 1
	for completed == false {
		if int(math.pow(36, count)) > nr {
			for i in 0 .. count {
				decimals << math.floor(f64(remaining / int(math.pow(36, count - 1 - i))))
				remaining = remaining % int(math.pow(36, count - 1 - i))
			}
			completed = true
		} else {
			count += 1
		}
	}
	mut strings := []string{}
	for i in 0 .. (decimals.len) {
		if decimals[i] >= 0 && decimals[i] <= 9 {
			strings << u8(decimals[i] + 48).ascii_str()
		} else {
			strings << u8(decimals[i] + 87).ascii_str()
		}
	}
	for{
		if strings.len<4{
			strings.insert(0,"0") 
		}else{
			break
		}

	}
	return strings.join('')
}

fn mytest() ! {
	for i in 1 .. 100000 {
		refcode := referral_code_get_random()!
		userid := referral_code_get_random()! // for test ok to do like this
		// TODO: measure time it took to do it
		set(refcode, userid)!
		// now get some random refcodes back and see if it matches
	}
}

mytest()!
