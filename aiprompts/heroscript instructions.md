# how to work with heroscript in vlang

## heroscript

Heroscript is our small scripting language which has following structure

an example of a heroscript is

```heroscript

!!dagu.script_define
	name: 'test_dag'
	homedir:''
	title:'a title'
	reset:1
	start:true //trie or 1 is same
	colors: 'green,red,purple' //lists are comma separated
	description: '
		a description can be multiline

		like this
		'


!!dagu.add_step
	dag: 'test_dag'
	name: 'hello_world'
	command: 'echo hello world'

!!dagu.add_step
	dag: 'test_dag'
	name: 'last_step'
	command: 'echo last step'


```

Notice how:
- every action starts with !!
	- the first part is the actor e.g. dagu in this case
	- the 2e part is the action name
- multilines are supported see the description field

## how to process heroscript in Vlang

- heroscript can be converted to a struct,
- the methods available to get the params are in 'params' section further in this doc


```vlang

fn test_play_dagu() ! {
	mut plbook := playbook.new(text: thetext_from_above)!
	play_dagu(mut plbook)! //see below in vlang block there it all happens
}


pub fn play_dagu(mut plbook playbook.PlayBook) ! {

	//find all actions are !!$actor.$actionname.  in this case above the actor is !!dagu, we check with the fitler if it exists, if not we return
	dagu_actions := plbook.find(filter: 'dagu.')!
	if dagu_actions.len == 0 {
		return
	}	
	play_dagu_basic(mut plbook)!
}

pub struct DaguScript {
pub mut:
	name string
	homedir string
	title string
	reset bool
	start bool
	colors []string
}

// play_dagu plays the dagu play commands
pub fn play_dagu_basic(mut plbook playbook.PlayBook) ! {

	//now find the specific ones for dagu.script_define
	mut actions := plbook.find(filter: 'dagu.script_define')!

	if actions.len > 0 {
		for myaction in actions {
			mut p := myaction.params       //get the params object from the action object, this can then be processed using the param getters      
			mut obj := DaguScript{
				//INFO: all details about the get methods can be found in 'params get methods' section
				name : p.get('name')! //will give error if not exist			
				homedir : p.get('homedir')!
				title : p.get_default('title', 'My Hero DAG')!  //uses a default if not set
				reset : p.get_default_false('reset') 
				start : p.get_default_true('start')
				colors : p.get_list('colors')
				description : p.get_default('description','')!					
			}
			... 
		}
	}

    //there can be more actions which will have other filter
	
}

```

## params get methods (param getters)

```vlang

fn (params &Params) exists(key_ string) bool

//check if arg exist (arg is just a value in the string e.g. red, not value:something) 
fn (params &Params) exists_arg(key_ string) bool

//see if the kwarg with the key exists if yes return as string trimmed
fn (params &Params) get(key_ string) !string

//return the arg with nr, 0 is the first    
fn (params &Params) get_arg(nr int) !string

//return arg, if the nr is larger than amount of args, will return the defval
fn (params &Params) get_arg_default(nr int, defval string) !string

fn (params &Params) get_default(key string, defval string) !string

fn (params &Params) get_default_false(key string) bool

fn (params &Params) get_default_true(key string) bool

fn (params &Params) get_float(key string) !f64

fn (params &Params) get_float_default(key string, defval f64) !f64

fn (params &Params) get_from_hashmap(key_ string, defval string, hashmap map[string]string) !string

fn (params &Params) get_int(key string) !int

fn (params &Params) get_int_default(key string, defval int) !int

//Looks for a list of strings in the parameters. ',' are used as deliminator to list
fn (params &Params) get_list(key string) ![]string

fn (params &Params) get_list_default(key string, def []string) ![]string

fn (params &Params) get_list_f32(key string) ![]f32

fn (params &Params) get_list_f32_default(key string, def []f32) []f32

fn (params &Params) get_list_f64(key string) ![]f64

fn (params &Params) get_list_f64_default(key string, def []f64) []f64

fn (params &Params) get_list_i16(key string) ![]i16

fn (params &Params) get_list_i16_default(key string, def []i16) []i16

fn (params &Params) get_list_i64(key string) ![]i64

fn (params &Params) get_list_i64_default(key string, def []i64) []i64

fn (params &Params) get_list_i8(key string) ![]i8

fn (params &Params) get_list_i8_default(key string, def []i8) []i8

fn (params &Params) get_list_int(key string) ![]int

fn (params &Params) get_list_int_default(key string, def []int) []int

fn (params &Params) get_list_namefix(key string) ![]string

fn (params &Params) get_list_namefix_default(key string, def []string) ![]string

fn (params &Params) get_list_u16(key string) ![]u16

fn (params &Params) get_list_u16_default(key string, def []u16) []u16

fn (params &Params) get_list_u32(key string) ![]u32

fn (params &Params) get_list_u32_default(key string, def []u32) []u32

fn (params &Params) get_list_u64(key string) ![]u64

fn (params &Params) get_list_u64_default(key string, def []u64) []u64

fn (params &Params) get_list_u8(key string) ![]u8

fn (params &Params) get_list_u8_default(key string, def []u8) []u8

fn (params &Params) get_map() map[string]string

fn (params &Params) get_path(key string) !string

fn (params &Params) get_path_create(key string) !string

fn (params &Params) get_percentage(key string) !f64

fn (params &Params) get_percentage_default(key string, defval string) !f64

//convert GB, MB, KB to bytes e.g. 10 GB becomes bytes in u64
fn (params &Params) get_storagecapacity_in_bytes(key string) !u64

fn (params &Params) get_storagecapacity_in_bytes_default(key string, defval u64) !u64

fn (params &Params) get_storagecapacity_in_gigabytes(key string) !u64

//Get Expiration object from time string input input can be either relative or absolute## Relative time
fn (params &Params) get_time(key string) !ourtime.OurTime

fn (params &Params) get_time_default(key string, defval ourtime.OurTime) !ourtime.OurTime

fn (params &Params) get_time_interval(key string) !Duration

fn (params &Params) get_timestamp(key string) !Duration

fn (params &Params) get_timestamp_default(key string, defval Duration) !Duration

fn (params &Params) get_u32(key string) !u32

fn (params &Params) get_u32_default(key string, defval u32) !u32

fn (params &Params) get_u64(key string) !u64

fn (params &Params) get_u64_default(key string, defval u64) !u64

fn (params &Params) get_u8(key string) !u8

fn (params &Params) get_u8_default(key string, defval u8) !u8

```

## how internally a heroscript gets parsed for params

- example to show how a heroscript gets parsed in action with params
- params are part of action object

```heroscript
example text to parse (heroscript)

id:a1 name6:aaaaa
name:'need to do something 1' 
description:
    '
    ## markdown works in it
    description can be multiline
    lets see what happens

    - a
    - something else

    ### subtitle
    '

name2:   test
name3: hi 
name10:'this is with space'  name11:aaa11

name4: 'aaa'

//somecomment
name5:   'aab'
```

the params are part of the action and are represented as follow for the above:

```vlang
Params{
    params: [Param{
        key: 'id'
        value: 'a1'
    }, Param{
        key: 'name6'
        value: 'aaaaa'
    }, Param{
        key: 'name'
        value: 'need to do something 1'
    }, Param{
        key: 'description'
        value: '## markdown works in it

                description can be multiline
                lets see what happens

                - a
                - something else

                ### subtitle
                '
        }, Param{
            key: 'name2'
            value: 'test'
        }, Param{
            key: 'name3'
            value: 'hi'
        }, Param{
            key: 'name10'
            value: 'this is with space'
        }, Param{
            key: 'name11'
            value: 'aaa11'
        }, Param{
            key: 'name4'
            value: 'aaa'
        }, Param{
            key: 'name5'
            value: 'aab'
        }]
    }
```