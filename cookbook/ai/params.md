```vlang
//Example how to use the paramsparser, can also be used as part from action parsing
import freeflowuniverse.crystallib.data.paramsparser

mut p:=paramsparser.new('
    id:a1 name6:aaaaa
    name:'need to do something 1' 
)!

assert "a1"==p.get_default("id","")!
```

```heroscript
example text to parse

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

results in
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

object & methods available in module:

```vlang
struct Param {
pub mut:
	key     string
	value   string
	comment string
}
struct Params {
pub mut:
	params   []Param
	args     []string
	comments []string
}


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
