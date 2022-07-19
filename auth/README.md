## Basic Auth

### Simple and small server with sqlite database has one table `[User]`

### There are just two endpoints

* for `Register` to create a new user with username and password.
* for `Login`, user will login with his cerdintials.

### There is an example of how to test and use it

<p>

Also, there is `basic_auth` middleware to decode users, you have to send it when you call this method

```v
    pub fn (mut app App) before_request() {
        basic_auth(
            {
                "<Username1>":"<Password1>",
                "<Username2>":"<Password2>",
            } 
            ,app
        ) or {
            panic(err)
        }
    }
```

</p>
