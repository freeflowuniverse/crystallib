# module osal


import as 

```vlang
import freeflowuniverse.crystallib.osal

osal.ping...

```

## ping

```go
assert ping(address:"338.8.8.8")==.unknownhost
assert ping(address:"8.8.8.8")==.ok
assert ping(address:"18.8.8.8")==.timeout
```

will do a panic if its not one of them, an unknown error

## platform

```go
if platform()==.osx{
    //do something
}

pub enum PlatformType {
    unknown
    osx
    ubuntu
    alpine
}

pub enum CPUType {
    unknown
    intel
    arm
    intel32
    arm32
}

```

## process


### execute jobs

```v
mut job2:=osal.exec(cmd:"ls /")?
println(job2)

//wont die, the result can be found in /tmp/execscripts
mut job:=osal.exec(cmd:"ls dsds",ignore_error:true)?
//this one has an error
println(job) 
```

All scripts are executed from a file from /tmp/execscripts

If the script executes well then its removed, so no leftovers, if it fails the script stays in the dir

### check process logs

```
mut pm:=process.processmap_get()?
```

info returns like:

```json
}, freeflowuniverse.crystallib.process.ProcessInfo{
        cpu_perc: 0
        mem_perc: 0
        cmd: 'mc'
        pid: 84455
        ppid: 84467
        rss: 3168
    }, freeflowuniverse.crystallib.process.ProcessInfo{
        cpu_perc: 0
        mem_perc: 0
        cmd: 'zsh -Z -g'
        pid: 84467
        ppid: 84469
        rss: 1360
    }]
```

## other commands

fn bin_path() !string
fn cmd_add(args_ CmdAddArgs) !
    copy a binary to the right location on the local computer . e.g. is /usr/local/bin on linux . e.g. is ~/hero/bin on osx . will also add the bin location to the path of .zprofile and .zshrc (different per platform)
fn cmd_exists(cmd string) bool
fn cmd_exists_profile(cmd string) bool
fn cmd_path(cmd string) !string
    is same as executing which in OS returns path or error
fn cmd_to_script_path(cmd Command) !string
    will return temporary path which then can be executed, is a helper function for making script out of command
fn cputype() CPUType
fn cputype_enum_from_string(cpytype string) CPUType
    Returns the enum value that matches the provided string for CPUType
fn dir_delete(path string) !
    remove all if it exists
fn dir_ensure(path string) !
    remove all if it exists
fn dir_reset(path string) !
    remove all if it exists and then (re-)create
fn done_delete(key string) !
fn done_exists(key string) bool
fn done_get(key string) ?string
fn done_get_int(key string) int
fn done_get_str(key string) string
fn done_print() !
fn done_reset() !
fn done_set(key string, val string) !
fn download(args_ DownloadArgs) !pathlib.Path
    if name is not specified, then will be the filename part if the last ends in an extension like .md .txt .log .text ... the file will be downloaded
fn env_get(key string) !string
    Returns the requested environment variable if it exists or throws an error if it does not
fn env_get_all() map[string]string
    Returns all existing environment variables
fn env_get_default(key string, def string) string
    Returns the requested environment variable if it exists or returns the provided default value if it does not
fn env_set(args EnvSet)
    Sets an environment if it was not set before, it overwrites the enviroment variable if it exists and if overwrite was set to true (default)
fn env_set_all(args EnvSetAll)
    Allows to set multiple enviroment variables in one go, if clear_before_set is true all existing environment variables will be unset before the operation, if overwrite_if_exists is set to true it will overwrite all existing enviromnent variables
fn env_unset(key string)
    Unsets an environment variable
fn env_unset_all()
    Unsets all environment variables
fn exec(cmd Command) !Job
    cmd is the cmd to execute can use ' ' and spaces . if \n in cmd it will write it to ext and then execute with bash . if die==false then will just return returncode,out but not return error . if stdout will show stderr and stdout . . if cmd starts with find or ls, will give to bash -c so it can execute . if cmd has no path, path will be found . . Command argument: .
    ```
     name                             string // to give a name to your command, good to see logs...
     cmd                              string
     description                      string
     timeout                          int  = 3600 // timeout in sec
     stdout                           bool = true
     stdout_log                       bool = true
     raise_error                      bool = true // if false, will not raise an error but still error report
     ignore_error                     bool // means if error will just exit and not raise, there will be no error reporting
     work_folder                      string // location where cmd will be executed
     environment                      map[string]string // env variables
     ignore_error_codes               []int
     scriptpath                       string // is the path where the script will be put which is executed
     scriptkeep                       bool   // means we don't remove the script
     debug                            bool   // if debug will put +ex in the script which is being executed and will make sure script stays
     shell                            bool   // means we will execute it in a shell interactive
     retry                            int
     interactive 					 	bool = true // make sure we run on non interactive way
     async							 bool
     runtime							 RunTime (.bash, .python)
    
     returns Job:
     start  time.Time
     end    time.Time
     cmd    Command
     output []string
     error    []string
     exit_code int
     status JobStatus
     process os.Process
    ```
    return Job .
fn exec_string(cmd Command) !string
    cmd is the cmd to execute can use ' ' and spaces if \n in cmd it will write it to ext and then execute with bash if die==false then will just return returncode,out but not return error if stdout will show stderr and stdout
    
    if cmd starts with find or ls, will give to bash -c so it can execute if cmd has no path, path will be found $... are remplaced by environment arguments TODO:implement
    
    Command argument: cmd string timeout int = 600 stdout bool = true die bool = true debug bool
    
    return what needs to be executed can give it to bash -c ...
fn execute_debug(cmd string) !string
fn execute_interactive(cmd string) !
    shortcut to execute a job interactive means in shell
fn execute_ok(cmd string) bool
    executes a cmd, if not error return true
fn execute_silent(cmd string) !string
    shortcut to execute a job silent
fn execute_stdout(cmd string) !string
    shortcut to execute a job to stdout
fn file_read(path string) !string
fn file_write(path string, text string) !
fn get_logger() log.Logger
    Returns a logger object and allows you to specify via environment argument OSAL_LOG_LEVEL the debug level
fn hero_path() !string
fn hostname() !string
fn initname() !string
    e.g. systemd, bash, zinit
fn ipaddr_pub_get() !string
    Returns the ipaddress as known on the public side is using resolver4.opendns.com
fn is_linux() bool
fn is_linux_arm() bool
fn is_linux_intel() bool
fn is_osx() bool
fn is_osx_arm() bool
fn is_osx_intel() bool
fn is_ubuntu() bool
fn load_env_file(file_path string) !
fn memdb_exists(key string) bool
fn memdb_get(key string) string
fn memdb_set(key string, val string)
fn package_install(name_ string) !
    install a package will use right commands per platform
fn package_refresh() !
    update the package list
fn ping(args PingArgs) PingResult
    if reached in timout result will be True address is e.g. 8.8.8.8 ping means we check if the destination responds
fn platform() PlatformType
fn platform_enum_from_string(platform string) PlatformType
fn process_exists(pid int) bool
fn process_exists_byname(name string) !bool
fn process_kill_recursive(args ProcessKillArgs) !
    kill process and all the ones underneith
fn processinfo_children(pid int) !ProcessMap
    get all children of 1 process
fn processinfo_get(pid int) !ProcessInfo
    get process info from 1 specific process returns
    ```
     pub struct ProcessInfo {
     pub mut:
     	cpu_perc	f32
     	mem_perc	f32
     	cmd 		string
     	pid 		int
     	ppid 		int
     	//resident memory
     	rss			int
     }
    ```
fn processinfo_get_byname(name string) ![]ProcessInfo
fn processinfo_with_children(pid int) !ProcessMap
    return the process and its children
fn processmap_get() !ProcessMap
    make sure to use new first, so that the connection has been initted then you can get it everywhere
fn profile_path() string
fn profile_path_add(args ProfilePathAddArgs) !
    add the following path to a profile
fn profile_path_add_hero() !string
fn profile_path_source() string
    return the source statement if the profile exists
fn profile_path_source_and() string
    return source $path &&  . or empty if it doesn't exist
fn sleep(duration int)
    sleep in seconds
fn tcp_port_test(args TcpPortTestArgs) bool
    test if a tcp port answers
    ```
     address string //192.168.8.8
     port int = 22
     timeout u16 = 2000 // total time in milliseconds to keep on trying
    ```
fn user_add(args UserArgs) !int
    add's a user if the user does not exist yet
fn user_exists(username string) bool
fn user_id_get(username string) !int
fn usr_local_path() !string
    /usr/local on linux, ${os.home_dir()}/hero on osx
fn whoami() !string
fn write_flags[T](options T) string
enum CPUType {
	unknown
	intel
	arm
	intel32
	arm32
}
enum ErrorType {
	exec
	timeout
	args
}
enum JobStatus {
	init
	running
	error_exec
	error_timeout
	error_args
	done
}
enum PMState {
	init
	ok
	old
}
enum PingResult {
	ok
	timeout     // timeout from ping
	unknownhost // means we don't know the hostname its a dns issue
}
enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
	arch
	suse
}
enum RunTime {
	bash
	python
	heroscript
	herocmd
	v
}
struct CmdAddArgs {
pub mut:
	cmdname string
	source  string @[required] // path where the binary is
	symlink bool // if rather than copy do a symlink
	reset   bool // if existing cmd will delete
	// bin_repo_url string = 'https://github.com/freeflowuniverse/freeflow_binary' // binary where we put the results
}
struct Command {
pub mut:
	name               string // to give a name to your command, good to see logs...
	cmd                string
	description        string
	timeout            int  = 3600 // timeout in sec
	stdout             bool = true
	stdout_log         bool = true
	raise_error        bool = true // if false, will not raise an error but still error report
	ignore_error       bool              // means if error will just exit and not raise, there will be no error reporting
	work_folder        string            // location where cmd will be executed
	environment        map[string]string // env variables
	ignore_error_codes []int
	scriptpath         string // is the path where the script will be put which is executed
	scriptkeep         bool   // means we don't remove the script
	debug              bool   // if debug will put +ex in the script which is being executed and will make sure script stays
	shell              bool   // means we will execute it in a shell interactive
	retry              int
	interactive        bool = true
	async              bool
	runtime            RunTime
}
struct DownloadArgs {
pub mut:
	name        string // optional (otherwise derived out of filename)
	url         string
	reset       bool   // will remove
	hash        string // if hash is known, will verify what hash is
	dest        string // if specified will copy to that destination	
	timeout     int = 180
	retry       int = 3
	minsize_kb  u32 = 10 // is always in kb
	maxsize_kb  u32
	expand_dir  string
	expand_file string
}
struct EnvSet {
pub mut:
	key       string @[required]
	value     string @[required]
	overwrite bool = true
}
struct EnvSetAll {
pub mut:
	env                 map[string]string
	clear_before_set    bool
	overwrite_if_exists bool = true
}
struct Job {
pub mut:
	start     time.Time
	end       time.Time
	cmd       Command
	output    string
	error     string
	exit_code int
	status    JobStatus
	process   ?&os.Process @[skip; str: skip]
	runnr     int // nr of time it runs, is for retry
}
fn (mut job Job) execute_retry() !
    execute the job and wait on result will retry as specified
fn (mut job Job) execute() !
    execute the job, start process, process will not be closed . important you need to close the process later by job.close()! otherwise we get zombie processes
fn (mut job Job) wait() !
    wait till the job finishes or goes in error
fn (mut job Job) process() !
    process (read std.err and std.out of process)
fn (mut job Job) close() !
    will wait & close
struct JobError {
	Error
pub mut:
	job        Job
	error_type ErrorType
}
struct PingArgs {
pub mut:
	address string @[required]
	count   u8  = 1 // the ping is successful if it got count amount of replies from the other side
	timeout u16 = 1 // the time in which the other side should respond in seconds
	retry   u8
}
struct ProcessInfo {
pub mut:
	cpu_perc f32
	mem_perc f32
	cmd      string
	pid      int
	ppid     int // parentpid
	// resident memory
	rss int
}
fn (mut p ProcessInfo) str() string
struct ProcessKillArgs {
pub mut:
	name string
	pid  int
}
struct ProcessMap {
pub mut:
	processes []ProcessInfo
	lastscan  time.Time
	state     PMState
	pids      []int
}
struct ProfilePathAddArgs {
pub mut:
	path     string @[required]
	todelete string // see which one to remove
}
struct TcpPortTestArgs {
pub mut:
	address string @[required] // 192.168.8.8
	port    int = 22
	timeout u16 = 2000 // total time in milliseconds to keep on trying
}
struct UserArgs {
pub mut:
	name string @[required]
}
*