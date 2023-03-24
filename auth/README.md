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

## ThreeFold Connect

### login using threefold connect.

#### get started.

* cd to `examples/threefold_connect`
* there is a file named `create_keys.v`, you have yo run this file to create `[public_key, private_key]` and save it into `./keys.toml` file.
* Once you have keys you can run the server.
    - go to `examples/threefold_connect/server`
    - type `v run .` in terminal.
    ##### Your server should be running under port `8000` now, and ready for requests.
* Once the server running you can now run the client.
    - go to `examples/threefold_connect/client`
    - type `v run .` in terminal.
    ##### Your client should be running under port `8080` now, and ready to make requests.
* Just go to [login page](http://localhost:8080/login) then it will redirect you to `ThreeFold connect login page`
* You have to write your username and make sure you have an account on `ThreeFold`.
* Confirm your login by pressing your pin in `ThreeFold Connect App`, then you'll return back to your client again.
* You maybe will have to remove `s` from your host if you running it on a local host.

#### Now you will see your email and username on the screen.

#### Installation.
##### You'll maybe want to install the following packages first.
```bash
    $ sudo apt-get install --quiet -y libsodium-dev
    $ v install libsodium
```