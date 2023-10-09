	
# Downloader

## downloader.get

Download using curl or git.

Also supports direct connections to a local path.

This tool will use git underneith if relevant (when git or http url).

#### Params    
    
- name         string
  - name of the download, if not specified then last part  of url
- downloadpath string  
  - the directory or file where we will download, will be /tmp/downloads/$name
- url          string 
  - url can be ssh:// https:// git:// file:// httpsfile:// or just a path
- reset        bool   
  - to remove all changes
- gitpull    bool   
  - NOT IMPLEMENTED YET
  -  if you want to force to pull the information
- minsize_kb   u32 
  - is always in kb
- maxsize_kb   u32
  - is always in kb
- dest         string 
  - if the dir or file needs to be copied somewhere
- destlink     bool = true 
  - if bool then will link the downloaded content to the dest
- hash         string 
  - if specified then will check the hash of the downloaded content
- metapath     string 
  - if not specified then will not write