# LuaDNS Vlang Module

## Overview
This module provides functionality to parse and manage DNS configurations from Lua scripts. It supports creating, updating, and validating DNS records for multiple domains.

## Features
- Parse Lua DNS configuration files.
- Manage DNS records for multiple domains.
- Validate IP addresses and domain names.
- Automatically add default CNAME and CAA records.

## Usage

### Load DNS Configurations
Load DNS configurations from a git repository.
```v
import luadns

// Load configurations from a git URL
dns := luadns.load('https://git.example.com/repo.git')!
```

### Set Domain
Add or update an A record for a domain or subdomain.
```v
dns.set_domain('example.com', '51.129.54.234')!
dns.set_domain('auth.example.com', '231.29.54.234')!
```

### Validate Inputs
The module ensures that only valid IP addresses and domain names are accepted.