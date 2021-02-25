struct User {
    name string
    age  int
}

// Note: T should be passed a struct name only
fn decode<T>(data string) T {
    mut result := T{}
    // compile-time `for` loop
    // T.fields gives an array of a field metadata type
    $for field in T.fields {
        $if field.typ is string {
            // $(string_expr) produces an identifier
            result.$(field.name) = data
        } $else $if field.typ is int {
            result.$(field.name) = 1
        }
    }
    return result
}

// println(@LINE)

println(decode<User>("s"))

// `decode<User>` generates:
// fn decode_User(data string) User {
//     mut result := User{}
//     result.name = get_string(data, 'name')
//     result.age = get_int(data, 'age')
//     return result
// }

//PRINTS:

// User{
//     name: 'a'
//     age: 1
// }