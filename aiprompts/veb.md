module veb
    # veb - the V Web Server
    
    A simple yet powerful web server with built-in routing, parameter handling, templating, and other features.
    
    ## Features
    
    - **Very fast** performance of C on the web.
    - **Templates are precompiled** all errors are visible at compilation time, not at runtime.
    - **Middleware** functionality similar to other big frameworks.
    - **Controllers** to split up your apps logic.
    - **Easy to deploy** just one binary file that also includes all templates. No need to install any
    dependencies.
    
    ## Quick Start
    
    Run your veb app with a live reload via `v -d veb_livereload watch run .`
    
    Now modifying any file in your web app (whether it's a .v file with the backend logic or a compiled .html template file) will result in an instant refresh of your app in the browser. No need to quit the app, rebuild it, and refresh the page in the browser!
    
    ## Deploying veb apps
    
    All the code, including HTML templates, is in one binary file. That's all you need to deploy. Use the `-prod` flag when building for production.
    
    ## Getting Started
    
    To start, you must import the module `veb` and define a structure which will represent your app and a structure which will represent the context of a request. These structures must be declared with the `pub` keyword.
    
    **Example:**
    
    ```v
    module main
    
    import veb
    
    pub struct User {
    pub mut:
    	name string
    	id   int
    }
    
    // Our context struct must embed `veb.Context`!
    pub struct Context {
    	veb.Context
    pub mut:
    	// In the context struct we store data that could be different
    	// for each request. Like a User struct or a session id
    	user       User
    	session_id string
    }
    
    pub struct App {
    pub:
    	// In the app struct we store data that should be accessible by all endpoints.
    	// For example, a database or configuration values.
    	secret_key string
    }
    
    // This is how endpoints are defined in veb. This is the index route
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	return ctx.text('Hello V! The secret key is "${app.secret_key}"')
    }
    
    fn main() {
    	mut app := &App{
    		secret_key: 'secret'
    	}
    	// Pass the App and context type and start the web server on port 8080
    	veb.run[App, Context](mut app, 8080)
    }
    ```
    
    You can use the `App` struct for data you want to keep during the lifetime of your program, or for data that you want to share between different routes.
    
    A new `Context` struct is created every time a request is received, so it can contain different data for each request.
    
    ## Defining endpoints
    
    To add endpoints to your web server, you must extend the `App` struct. For routing you can either use auto-mapping of function names or specify the path as an attribute. The function expects a parameter of your Context type and a response of the type `veb.Result`.
    
    **Example:**
    
    ```v ignore
    // This endpoint can be accessed via http://server:port/hello
    pub fn (app &App) hello(mut ctx Context) veb.Result {
    	return ctx.text('Hello')
    }
    
    // This endpoint can be accessed via http://server:port/foo
    @['/foo']
    pub fn (app &App) world(mut ctx Context) veb.Result {
    	return ctx.text('World')
    }
    ```
    
    ### HTTP verbs
    
    To use any HTTP verbs (or methods, as they are properly called), such as `@[post]`, `@[get]`, `@[put]`, `@[patch]` or `@[delete]` you can simply add the attribute before the function definition.
    
    **Example:**
    
    ```v ignore
    // only GET requests to http://server:port/world are handled by this method
    @[get]
    pub fn (app &App) world(mut ctx Context) veb.Result {
    	return ctx.text('World')
    }
    
    // only POST requests to http://server:port/product/create are handled by this method
    @['/product/create'; post]
    pub fn (app &App) create_product(mut ctx Context) veb.Result {
    	return ctx.text('product')
    }
    ```
    
    By default, endpoints are marked as GET requests only. It is also possible to add multiple HTTP verbs per endpoint.
    
    **Example:**
    
    ```v ignore
    // only GET and POST requests to http://server:port/login are handled by this method
    @['/login'; get; post]
    pub fn (app &App) login(mut ctx Context) veb.Result {
    	if ctx.req.method == .get {
    		// show the login page on a GET request
    		return ctx.html('<h1>Login page</h1><p>todo: make form</p>')
    	} else {
    		// request method is POST
    		password := ctx.form['password']
    		// validate password length
    		if password.len < 12 {
    			return ctx.text('password is too weak!')
    		} else {
    			// we receive a POST request, so we want to explicitly tell the browser
    			// to send a GET request to the profile page.
    			return ctx.redirect('/profile')
    		}
    	}
    }
    ```
    
    ### Routes with Parameters
    
    Parameters are passed directly to an endpoint route using the colon sign `:`. The route parameters are passed as arguments. V will cast the parameter to any of V's primitive types (`string`, `int` etc,).
    
    To pass a parameter to an endpoint, you simply define it inside an attribute, e. g. `@['/hello/:user]`. After it is defined in the attribute, you have to add it as a function parameter.
    
    **Example:**
    
    ```v ignore
    // V will pass the parameter 'user' as a string
               vvvv
    @['/hello/:user']                             vvvv
    pub fn (app &App) hello_user(mut ctx Context, user string) veb.Result {
    	return ctx.text('Hello ${user}')
    }
    
    // V will pass the parameter 'id' as an int
                  vv
    @['/document/:id']                              vv
    pub fn (app &App) get_document(mut ctx Context, id int) veb.Result {
    	return ctx.text('Hello ${user}')
    }
    ```
    
    If we visit http://localhost:port/hello/vaesel we would see the text `Hello vaesel`.
    
    ### Routes with Parameter Arrays
    
    If you want multiple parameters in your route and if you want to parse the parameters yourself, or you want a wildcard route, you can add `...` after the `:` and name, e.g. `@['/:path...']`.
    
    This will match all routes after `'/'`. For example, the url `/path/to/test` would give `path = '/path/to/test'`.
    
    ```v ignore
             vvv
    @['/:path...']                              vvvv
    pub fn (app &App) wildcard(mut ctx Context, path string) veb.Result {
    	return ctx.text('URL path = "${path}"')
    }
    ```
    
    ### Query, Form and Files
    
    You have direct access to query values by accessing the `query` field on your context struct. You are also able to access any formdata or files that were sent with the request with the fields `.form` and `.files` respectively.
    
    In the following example, visiting http://localhost:port/user?name=veb we will see the text `Hello veb!`. And if we access the route without the `name` parameter, http://localhost:port/user, we will see the text `no user was found`,
    
    **Example:**
    
    ```v ignore
    @['/user'; get]
    pub fn (app &App) get_user_by_id(mut ctx Context) veb.Result {
    	user_name := ctx.query['name'] or {
    		// we can exit early and send a different response if no `name` parameter was passed
    		return ctx.text('no user was found')
    	}
    
    	return ctx.text('Hello ${user_name}!')
    }
    ```
    
    ### Host
    
    To restrict an endpoint to a specific host, you can use the `host` attribute followed by a colon `:` and the host name. You can test the Host feature locally by adding a host to the "hosts" file of your device.
    
    **Example:**
    
    ```v ignore
    @['/'; host: 'example.com']
    pub fn (app &App) hello_web(mut ctx Context) veb.Result {
    	return app.text('Hello World')
    }
    
    @['/'; host: 'api.example.org']
    pub fn (app &App) hello_api(mut ctx Context) veb.Result {
    	return ctx.text('Hello API')
    }
    
    // define the handler without a host attribute last if you have conflicting paths.
    @['/']
    pub fn (app &App) hello_others(mut ctx Context) veb.Result {
    	return ctx.text('Hello Others')
    }
    ```
    
    You can also [create a controller](#controller-with-hostname) to handle all requests from a specific host in one app struct.
    
    ### Route Matching Order
    
    veb will match routes in the order that you define endpoints.
    
    **Example:**
    
    ```v ignore
    @['/:path']
    pub fn (app &App) with_parameter(mut ctx Context, path string) veb.Result {
    	return ctx.text('from with_parameter, path: "${path}"')
    }
    
    @['/normal']
    pub fn (app &App) normal(mut ctx Context) veb.Result {
    	return ctx.text('from normal')
    }
    ```
    
    In this example we defined an endpoint with a parameter first. If we access our app on the url http://localhost:port/normal we will not see `from normal`, but `from with_parameter, path: "normal"`.
    
    ### Custom not found page
    
    You can implement a `not_found` endpoint that is called when a request is made, and no matching route is found to replace the default HTTP 404 not found page. This route has to be defined on our Context struct.
    
    **Example:**
    
    ```v ignore
    pub fn (mut ctx Context) not_found() veb.Result {
    	// set HTTP status 404
    	ctx.res.set_status(.not_found)
    	return ctx.html('<h1>Page not found!</h1>')
    }
    ```
    
    ## Static files and website
    
    veb also provides a way of handling static files. We can mount a folder at the root of our web app, or at a custom route. To start using static files we have to embed `veb.StaticHandler` on our app struct.
    
    **Example:**
    
    Let's say you have the following file structure:
    
    ```
    .
    ├── static/
    │   ├── css/
    │   │   └── main.css
    │   └── js/
    │       └── main.js
    └── main.v
    ```
    
    If we want all the documents inside the `static` sub-directory to be publicly accessible, we can use `handle_static`.
    
    > **Note:** > veb will recursively search the folder you mount; all the files inside that folder > will be publicly available.
    
    _main.v_
    
    ```v
    module main
    
    import veb
    
    pub struct Context {
    	veb.Context
    }
    
    pub struct App {
    	veb.StaticHandler
    }
    
    fn main() {
    	mut app := &App{}
    
    	app.handle_static('static', false)!
    
    	veb.run[App, Context](mut app, 8080)
    }
    ```
    
    If we start the app with `v run main.v` we can access our `main.css` file at http://localhost:8080/static/css/main.css
    
    ### Mounting folders at specific locations
    
    In the previous example the folder `static` was mounted at `/static`. We could also choose to mount the static folder at the root of our app: everything inside the `static` folder is available at `/`.
    
    **Example:**
    
    ```v ignore
    // change the second argument to `true` to mount a folder at the app root
    app.handle_static('static', true)!
    ```
    
    We can now access `main.css` directly at http://localhost:8080/css/main.css.
    
    If a request is made to the root of a static folder, veb will look for an `index.html` or `ìndex.htm` file and serve it if available. Thus, it's also a good way to host a complete website. An example is available [here](/examples/veb/static_website).
    
    It is also possible to mount the `static` folder at a custom path.
    
    **Example:**
    
    ```v ignore
    // mount the folder 'static' at path '/public', the path has to start with '/'
    app.mount_static_folder_at('static', '/public')
    ```
    
    If we run our app the `main.css` file is available at http://localhost:8080/public/main.css
    
    ### Adding a single static asset
    
    If you don't want to mount an entire folder, but only a single file, you can use `serve_static`.
    
    **Example:**
    
    ```v ignore
    // serve the `main.css` file at '/path/main.css'
    app.serve_static('/path/main.css',  'static/css/main.css')!
    ```
    
    ### Dealing with MIME types
    
    By default, veb will map the extension of a file to a MIME type. If any of your static file's extensions do not have a default MIME type in veb, veb will throw an error and you have to add your MIME type to `.static_mime_types` yourself.
    
    **Example:**
    
    Given the following file structure:
    
    ```
    .
    ├── static/
    │   └── file.what
    └── main.v
    ```
    
    ```v ignore
    app.handle_static('static', true)!
    ```
    
    This code will throw an error, because veb has no default MIME type for a `.what` file extension.
    
    ```
    unknown MIME type for file extension ".what"
    ```
    
    To fix this we have to provide a MIME type for the `.what` file extension:
    
    ```v ignore
    app.static_mime_types['.what'] = 'txt/plain'
    app.handle_static('static', true)!
    ```
    
    ## Middleware
    
    Middleware in web development is (loosely defined) a hidden layer that sits between what a user requests (the HTTP Request) and what a user sees (the HTTP Response). We can use this middleware layer to provide "hidden" functionality to our apps endpoints.
    
    To use veb's middleware we have to embed `veb.Middleware` on our app struct and provide the type of which context struct should be used.
    
    **Example:**
    
    ```v ignore
    pub struct App {
    	veb.Middleware[Context]
    }
    ```
    
    ### Use case
    
    We could, for example, get the cookies for an HTTP request and check if the user has already accepted our cookie policy. Let's modify our Context struct to store whether the user has accepted our policy or not.
    
    **Example:**
    
    ```v ignore
    pub struct Context {
    	veb.Context
    pub mut:
    	has_accepted_cookies bool
    }
    ```
    
    In veb middleware functions take a `mut` parameter with the type of your context struct and must return `bool`. We have full access to modify our Context struct!
    
    The return value indicates to veb whether it can continue or has to stop. If we send a response to the client in a middleware function veb has to stop, so we return `false`.
    
    **Example:**
    
    ```v ignore
    pub fn check_cookie_policy(mut ctx Context) bool {
    	// get the cookie
    	cookie_value := ctx.get_cookie('accepted_cookies') or { '' }
    	// check if the cookie has been set
    	if cookie_value == 'true' {
    		ctx.has_accepted_cookies = true
    	}
    	// we don't send a response, so we must return true
    	return true
    }
    ```
    
    We can check this value in an endpoint and return a different response.
    
    **Example:**
    
    ```v ignore
    @['/only-cookies']
    pub fn (app &App) only_cookie_route(mut ctx Context) veb.Result {
    	if ctx.has_accepted_cookies {
    		return ctx.text('Welcome!')
    	} else {
    		return ctx.text('You must accept the cookie policy!')
    	}
    }
    ```
    
    There is one thing left for our middleware to work: we have to register our `only_cookie_route` function as middleware for our app. We must do this after the app is created and before the app is started.
    
    **Example:**
    
    ```v ignore
    fn main() {
    	mut app := &App{}
    
    	// register middleware for all routes
    	app.use(handler: check_cookie_policy)
    
    	// Pass the App and context type and start the web server on port 8080
    	veb.run[App, Context](mut app, 8080)
    }
    ```
    
    ### Types of middleware
    
    In the previous example we used so called "global" middleware. This type of middleware applies to every endpoint defined on our app struct; global. It is also possible to register middleware for only a certain route(s).
    
    **Example:**
    
    ```v ignore
    // register middleware only for the route '/auth'
    app.route_use('/auth', handler: auth_middleware)
    // register middleware only for the route '/documents/' with a parameter
    // e.g. '/documents/5'
    app.route_use('/documents/:id')
    // register middleware with a parameter array. The middleware will be registered
    // for all routes that start with '/user/' e.g. '/user/profile/update'
    app.route_use('/user/:path...')
    ```
    
    ### Evaluation moment
    
    By default, the registered middleware functions are executed *before* a method on your app struct is called. You can also change this behaviour to execute middleware functions *after* a method on your app struct is called, but before the response is sent!
    
    **Example:**
    
    ```v ignore
    pub fn modify_headers(mut ctx Context) bool {
    	// add Content-Language: 'en-US' header to each response
    	ctx.res.header.add(.content_language, 'en-US')
    	return true
    }
    ```
    
    ```v ignore
    app.use(handler: modify_headers, after: true)
    ```
    
    #### When to use which type
    
    You could use "before" middleware to check and modify the HTTP request and you could use "after" middleware to validate the HTTP response that will be sent or do some cleanup.
    
    Anything you can do in "before" middleware, you can do in "after" middleware.
    
    ### Evaluation order
    
    veb will handle requests in the following order:
    
    1. Execute global "before" middleware
    2. Execute "before" middleware that matches the requested route
    3. Execute the endpoint handler on your app struct
    4. Execute global "after" middleware
    5. Execute "after" middleware that matches the requested route
    
    In each step, except for step `3`, veb will evaluate the middleware in the order that they are registered; when you call `app.use` or `app.route_use`.
    
    ### Early exit
    
    If any middleware sends a response (and thus must return `false`) veb will not execute any other middleware, or the endpoint method, and immediately send the response.
    
    **Example:**
    
    ```v ignore
    pub fn early_exit(mut ctx Context) bool {
    	ctx.text('early exit')
    	// we send a response from middleware, so we have to return false
    	return false
    }
    
    pub fn logger(mut ctx Context) bool {
    	println('received request for "${ctx.req.url}"')
    	return true
    }
    ```
    
    ```v ignore
    app.use(handler: early_exit)
    app.use(handler: logger)
    ```
    
    Because we register `early_exit` before `logger` our logging middleware will never be executed!
    
    ## Controllers
    
    Controllers can be used to split up your app logic so you are able to have one struct per "route group". E.g. a struct `Admin` for urls starting with `'/admin'` and a struct `Foo` for urls starting with `'/foo'`.
    
    To use controllers we have to embed `veb.Controller` on our app struct and when we register a controller we also have to specify what the type of the context struct will be. That means that it is possible to have a different context struct for each controller and the main app struct.
    
    **Example:**
    
    ```v
    module main
    
    import veb
    
    pub struct Context {
    	veb.Context
    }
    
    pub struct App {
    	veb.Controller
    }
    
    // this endpoint will be available at '/'
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	return ctx.text('from app')
    }
    
    pub struct Admin {}
    
    // this endpoint will be available at '/admin/'
    pub fn (app &Admin) index(mut ctx Context) veb.Result {
    	return ctx.text('from admin')
    }
    
    pub struct Foo {}
    
    // this endpoint will be available at '/foo/'
    pub fn (app &Foo) index(mut ctx Context) veb.Result {
    	return ctx.text('from foo')
    }
    
    fn main() {
    	mut app := &App{}
    
    	// register the controllers the same way as how we start a veb app
    	mut admin_app := &Admin{}
    	app.register_controller[Admin, Context]('/admin', mut admin_app)!
    
    	mut foo_app := &Foo{}
    	app.register_controller[Foo, Context]('/foo', mut foo_app)!
    
    	veb.run[App, Context](mut app, 8080)
    }
    ```
    
    You can do everything with a controller struct as with a regular `App` struct. Register middleware, add static files and you can even register other controllers!
    
    ### Routing
    
    Any route inside a controller struct is treated as a relative route to its controller namespace.
    
    ```v ignore
    @['/path']
    pub fn (app &Admin) path(mut ctx Context) veb.Result {
        return ctx.text('Admin')
    }
    ```
    
    When we registered the controller with `app.register_controller[Admin, Context]('/admin', mut admin_app)!` we told veb that the namespace of that controller is `'/admin'` so in this example we would see the text "Admin" if we navigate to the url `'/admin/path'`.
    
    veb doesn't support duplicate routes, so if we add the following route to the example the code will produce an error.
    
    ```v ignore
    @['/admin/path']
    pub fn (app &App) admin_path(mut ctx Context) veb.Result {
        return ctx.text('Admin overwrite')
    }
    ```
    
    There will be an error, because the controller `Admin` handles all routes starting with `'/admin'`: the endpoint `admin_path` is unreachable.
    
    ### Controller with hostname
    
    You can also set a host for a controller. All requests coming to that host will be handled by the controller.
    
    **Example:**
    
    ```v ignore
    struct Example {}
    
    // You can only access this route at example.com: http://example.com/
    pub fn (app &Example) index(mut ctx Context) veb.Result {
    	return ctx.text('Example')
    }
    ```
    
    ```v ignore
    mut example_app := &Example{}
    // set the controllers hostname to 'example.com' and handle all routes starting with '/',
    // we handle requests with any route to 'example.com'
    app.register_controller[Example, Context]('example.com', '/', mut example_app)!
    ```
    
    ## Context Methods
    
    veb has a number of utility methods that make it easier to handle requests and send responses. These methods are available on `veb.Context` and directly on your own context struct if you embed `veb.Context`. Below are some of the most used methods, look at the [standard library documentation](https://modules.vlang.io/) to see them all.
    
    ### Request methods
    
    You can directly access the HTTP request on the `.req` field.
    
    #### Get request headers
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	content_length := ctx.get_header(.content_length) or { '0' }
    	// get custom header
    	custom_header := ctx.get_custom_header('X-HEADER') or { '' }
    	// ...
    }
    ```
    
    #### Get a cookie
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	cookie_val := ctx.get_cookie('token') or { '' }
    	// ...
    }
    ```
    
    ### Response methods
    
    You can directly modify the HTTP response by changing the `res` field, which is of the type `http.Response`.
    
    #### Send response with different MIME types
    
    ```v ignore
    // send response HTTP_OK with content-type `text/html`
    ctx.html('<h1>Hello world!</h1>')
    // send response HTTP_OK with content-type `text/plain`
    ctx.text('Hello world!')
    // stringify the object and send response HTTP_OK with content-type `application/json`
    ctx.json(User{
    	name: 'test'
    	age: 20
    })
    ```
    
    #### Sending files
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) file_response(mut ctx Context) veb.Result {
    	// send the file 'image.png' in folder 'data' to the user
    	return ctx.file('data/image.png')
    }
    ```
    
    #### Set response headers
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	ctx.set_header(.accept, 'text/html')
    	// set custom header
    	ctx.set_custom_header('X-HEADER', 'my-value')!
    	// ...
    }
    ```
    
    #### Set a cookie
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	ctx.set_cookie(http.Cookie{
    		name: 'token'
    		value: 'true'
    		path: '/'
    		secure: true
    		http_only: true
    	})
    	// ...
    }
    ```
    
    #### Redirect
    
    You must pass the type of redirect to veb:
    
    - `moved_permanently` HTTP code 301
    - `found` HTTP code 302
    - `see_other` HTTP code 303
    - `temporary_redirect` HTTP code 307
    - `permanent_redirect` HTTP code 308
    
    **Common use cases:**
    
    If you want to change the request method, for example when you receive a post request and want to redirect to another page via a GET request, you should use `see_other`. If you want the HTTP method to stay the same, you should use `found` generally speaking.
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	token := ctx.get_cookie('token') or { '' }
    	if token == '' {
    		// redirect the user to '/login' if the 'token' cookie is not set
    		// we explicitly tell the browser to send a GET request
    		return ctx.redirect('/login', typ: .see_other)
    	} else {
    		return ctx.text('Welcome!')
    	}
    }
    ```
    
    #### Sending error responses
    
    **Example:**
    
    ```v ignore
    pub fn (app &App) login(mut ctx Context) veb.Result {
    	if username := ctx.form['username'] {
    		return ctx.text('Hello "${username}"')
    	} else {
    		// send an HTTP 400 Bad Request response with a message
    		return ctx.request_error('missing form value "username"')
    	}
    }
    ```
    
    You can also use `ctx.server_error(msg string)` to send an HTTP 500 internal server error with a message.
    
    ## Advanced usage
    
    If you need more control over the TCP connection with a client, for example when you want to keep the connection open. You can call `ctx.takeover_conn`.
    
    When this function is called you are free to do anything you want with the TCP connection and veb will not interfere. This means that we are responsible for sending a response over the connection and closing it.
    
    ### Empty Result
    
    Sometimes you want to send the response in another thread, for example when using [Server Sent Events](sse/README.md). When you are sure that a response will be sent over the TCP connection you can return `veb.no_result()`. This function does nothing and returns an empty `veb.Result` struct, letting veb know that we sent a response ourselves.
    
    > **Note:** > It is important to call `ctx.takeover_conn` before you spawn a thread
    
    **Example:**
    
    ```v
    module main
    
    import net
    import time
    import veb
    
    pub struct Context {
    	veb.Context
    }
    
    pub struct App {}
    
    pub fn (app &App) index(mut ctx Context) veb.Result {
    	return ctx.text('hello!')
    }
    
    @['/long']
    pub fn (app &App) long_response(mut ctx Context) veb.Result {
    	// let veb know that the connection should not be closed
    	ctx.takeover_conn()
    	// use spawn to handle the connection in another thread
    	// if we don't the whole web server will block for 10 seconds,
    	// since veb is singlethreaded
    	spawn handle_connection(mut ctx.conn)
    	// we will send a custom response ourselves, so we can safely return an empty result
    	return veb.no_result()
    }
    
    fn handle_connection(mut conn net.TcpConn) {
    	defer {
    		conn.close() or {}
    	}
    	// block for 10 second
    	time.sleep(time.second * 10)
    	conn.write_string('HTTP/1.1 200 OK\r\nContent-type: text/html\r\nContent-length: 15\r\n\r\nHello takeover!') or {}
    }
    
    fn main() {
    	mut app := &App{}
    	veb.run[App, Context](mut app, 8080)
    }
    ```
    

const methods_with_form = [http.Method.post, .put, .patch]
const http_404 = http.new_response(
	status: .not_found
	body:   '404 Not Found'
	header: http.new_header(
		key:   .content_type
		value: 'text/plain'
	).join(headers_close)
)
const max_http_post_size = 1024 * 1024
const http_408 = http.new_response(
	status: .request_timeout
	body:   '408 Request Timeout'
	header: http.new_header(
		key:   .content_type
		value: 'text/plain'
	).join(headers_close)
)
const default_port = 8080
const cors_safelisted_response_headers = [http.CommonHeader.cache_control, .content_language,
	.content_length, .content_type, .expires, .last_modified, .pragma].map(it.str())
const mime_types = {
	'.aac':    'audio/aac'
	'.abw':    'application/x-abiword'
	'.arc':    'application/x-freearc'
	'.avi':    'video/x-msvideo'
	'.azw':    'application/vnd.amazon.ebook'
	'.bin':    'application/octet-stream'
	'.bmp':    'image/bmp'
	'.bz':     'application/x-bzip'
	'.bz2':    'application/x-bzip2'
	'.cda':    'application/x-cdf'
	'.csh':    'application/x-csh'
	'.css':    'text/css'
	'.csv':    'text/csv'
	'.doc':    'application/msword'
	'.docx':   'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
	'.eot':    'application/vnd.ms-fontobject'
	'.epub':   'application/epub+zip'
	'.gz':     'application/gzip'
	'.gif':    'image/gif'
	'.htm':    'text/html'
	'.html':   'text/html'
	'.ico':    'image/vnd.microsoft.icon'
	'.ics':    'text/calendar'
	'.jar':    'application/java-archive'
	'.jpeg':   'image/jpeg'
	'.jpg':    'image/jpeg'
	'.js':     'text/javascript'
	'.json':   'application/json'
	'.jsonld': 'application/ld+json'
	'.mid':    'audio/midi audio/x-midi'
	'.midi':   'audio/midi audio/x-midi'
	'.mjs':    'text/javascript'
	'.mp3':    'audio/mpeg'
	'.mp4':    'video/mp4'
	'.mpeg':   'video/mpeg'
	'.mpkg':   'application/vnd.apple.installer+xml'
	'.odp':    'application/vnd.oasis.opendocument.presentation'
	'.ods':    'application/vnd.oasis.opendocument.spreadsheet'
	'.odt':    'application/vnd.oasis.opendocument.text'
	'.oga':    'audio/ogg'
	'.ogv':    'video/ogg'
	'.ogx':    'application/ogg'
	'.opus':   'audio/opus'
	'.otf':    'font/otf'
	'.png':    'image/png'
	'.pdf':    'application/pdf'
	'.php':    'application/x-httpd-php'
	'.ppt':    'application/vnd.ms-powerpoint'
	'.pptx':   'application/vnd.openxmlformats-officedocument.presentationml.presentation'
	'.rar':    'application/vnd.rar'
	'.rtf':    'application/rtf'
	'.sh':     'application/x-sh'
	'.svg':    'image/svg+xml'
	'.swf':    'application/x-shockwave-flash'
	'.tar':    'application/x-tar'
	'.tif':    'image/tiff'
	'.tiff':   'image/tiff'
	'.ts':     'video/mp2t'
	'.ttf':    'font/ttf'
	'.txt':    'text/plain'
	'.vsd':    'application/vnd.visio'
	'.wasm':   'application/wasm'
	'.wav':    'audio/wav'
	'.weba':   'audio/webm'
	'.webm':   'video/webm'
	'.webp':   'image/webp'
	'.woff':   'font/woff'
	'.woff2':  'font/woff2'
	'.xhtml':  'application/xhtml+xml'
	'.xls':    'application/vnd.ms-excel'
	'.xlsx':   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
	'.xml':    'application/xml'
	'.xul':    'application/vnd.mozilla.xul+xml'
	'.zip':    'application/zip'
	'.3gp':    'video/3gpp'
	'.3g2':    'video/3gpp2'
	'.7z':     'application/x-7z-compressed'
	'.m3u8':   'application/vnd.apple.mpegurl'
	'.vsh':    'text/x-vlang'
	'.v':      'text/x-vlang'
}
const http_500 = http.new_response(
	status: .internal_server_error
	body:   '500 Internal Server Error'
	header: http.new_header(
		key:   .content_type
		value: 'text/plain'
	).join(headers_close)
)
const http_400 = http.new_response(
	status: .bad_request
	body:   '400 Bad Request'
	header: http.new_header(
		key:   .content_type
		value: 'text/plain'
	).join(headers_close)
)
const http_413 = http.new_response(
	status: .request_entity_too_large
	body:   '413 Request entity is too large'
	header: http.new_header(
		key:   .content_type
		value: 'text/plain'
	).join(headers_close)
)
const http_302 = http.new_response(
	status: .found
	body:   '302 Found'
	header: headers_close
)
const headers_close = http.new_custom_header_from_map({
	'Server': 'veb'
}) or { panic('should never fail') }
fn controller[A, X](path string, mut global_app A) !&ControllerPath
    controller generates a new Controller for the main app
fn controller_host[A, X](host string, path string, mut global_app A) &ControllerPath
    controller_host generates a controller which only handles incoming requests from the `host` domain
fn cors[T](options CorsOptions) MiddlewareOptions[T]
    cors handles cross-origin requests by adding Access-Control-* headers to a preflight request and validating the headers of a cross-origin request.
    Example: 
    app.use(veb.cors[Context](veb.CorsOptions{
        origins: ['*']
        allowed_methods: [.get, .head, .patch, .put, .post, .delete]
    }))
fn decode_gzip[T]() MiddlewareOptions[T]
    decode_gzip decodes the body of a gzip'ed HTTP request. Register this middleware before you do anything with the request body!
    Example: app.use(veb.decode_gzip[Context]())
fn encode_gzip[T]() MiddlewareOptions[T]
    encode_gzip adds gzip encoding to the HTTP Response body. This middleware does not encode files, if you return `ctx.file()`. Register this middleware as last!
    Example: app.use(veb.encode_gzip[Context]())
fn no_result() Result
    no_result does nothing, but returns `veb.Result`. Only use it when you are sure a response will be send over the connection, or in combination with `Context.takeover_conn`
fn run[A, X](mut global_app A, port int)
    run - start a new veb server, listening to all available addresses, at the specified `port`
fn run_at[A, X](mut global_app A, params RunParams) !
    run_at - start a new veb server, listening only on a specific address `host`, at the specified `port`
    Example: veb.run_at(new_app(), veb.RunParams{ host: 'localhost' port: 8099 family: .ip }) or { panic(err) }
interface StaticApp {
mut:
	static_files      map[string]string
	static_mime_types map[string]string
	static_hosts      map[string]string
}
fn (mut fr FileResponse) done()
    close the open file and reset the struct to its default values
type MiddlewareHandler[T] = fn (mut T) bool
fn (m &Middleware[T]) str() string
    string representation of Middleware
fn (mut m Middleware[T]) use(options MiddlewareOptions[T])
    use registers a global middleware handler
fn (mut m Middleware[T]) route_use(route string, options MiddlewareOptions[T])
    route_use registers a middleware handler for a specific route(s)
type RawHtml = string
    A type which doesn't get filtered inside templates
fn (mut params RequestParams) request_done(fd int)
    reset request parameters for `fd`: reset content-length index and the http request
fn (mut sr StringResponse) done()
    free the current string and reset the struct to its default values
enum RedirectType {
	found              = int(http.Status.found)
	moved_permanently  = int(http.Status.moved_permanently)
	see_other          = int(http.Status.see_other)
	temporary_redirect = int(http.Status.temporary_redirect)
	permanent_redirect = int(http.Status.permanent_redirect)
}
struct Context {
mut:
	// veb will try to infer the content type base on file extension,
	// and if `content_type` is not empty the `Content-Type` header will always be
	// set to this value
	content_type string
	// done is set to true when a response can be sent over `conn`
	done bool
	// if true the response should not be sent and the connection should be closed
	// manually.
	takeover bool
	// how the http response should be handled by veb's backend
	return_type ContextReturnType = .normal
	return_file string
	// If the `Connection: close` header is present the connection should always be closed
	client_wants_to_close bool
pub:
	// TODO: move this to `handle_request`
	// time.ticks() from start of veb connection handle.
	// You can use it to determine how much time is spent on your request.
	page_gen_start i64
pub mut:
	req               http.Request
	custom_mime_types map[string]string
	// TCP connection to client. Only for advanced usage!
	conn &net.TcpConn = unsafe { nil }
	// Map containing query params for the route.
	// http://localhost:3000/index?q=vpm&order_by=desc => { 'q': 'vpm', 'order_by': 'desc' }
	query map[string]string
	// Multipart-form fields.
	form map[string]string
	// Files from multipart-form.
	files map[string][]http.FileData
	res   http.Response
	// use form_error to pass errors from the context to your frontend
	form_error                  string
	livereload_poll_interval_ms int = 250
}
    The Context struct represents the Context which holds the HTTP request and response. It has fields for the query, form, files and methods for handling the request and response
fn (mut ctx Context) before_request() Result
    before_request is always the first function that is executed and acts as middleware
fn (mut ctx Context) error(s string)
    Set s to the form error
fn (mut ctx Context) file(file_path string) Result
    Response HTTP_OK with file as payload
fn (ctx &Context) get_cookie(key string) ?string
    Gets a cookie by a key
fn (ctx &Context) get_custom_header(key string) !string
    returns the request header data from the key
fn (ctx &Context) get_header(key http.CommonHeader) !string
    returns the request header data from the key
fn (mut ctx Context) html(s string) Result
    Response with payload and content-type `text/html`
fn (ctx &Context) ip() string
    Returns the ip address from the current user
fn (mut ctx Context) json[T](j T) Result
    Response with json_s as payload and content-type `application/json`
fn (mut ctx Context) json_pretty[T](j T) Result
    Response with a pretty-printed JSON result
fn (mut ctx Context) not_found() Result
    returns a HTTP 404 response
fn (mut ctx Context) ok(s string) Result
    Response HTTP_OK with s as payload
fn (mut ctx Context) redirect(url string, params RedirectParams) Result
    Redirect to an url
fn (mut ctx Context) request_error(msg string) Result
    send an error 400 with a message
fn (mut ctx Context) send_response_to_client(mimetype string, response string) Result
    send_response_to_client finalizes the response headers and sets Content-Type to `mimetype` and the response body to `response`
fn (mut ctx Context) server_error(msg string) Result
    send an error 500 with a message
fn (mut ctx Context) set_content_type(mime string)
    set_content_type sets the Content-Type header to `mime`
fn (mut ctx Context) set_cookie(cookie http.Cookie)
    Sets a cookie
fn (mut ctx Context) set_custom_header(key string, value string) !
    set a custom header on the response object
fn (mut ctx Context) set_header(key http.CommonHeader, value string)
    set a header on the response object
fn (mut ctx Context) takeover_conn()
    takeover_conn prevents veb from automatically sending a response and closing the connection. You are responsible for closing the connection. In takeover mode if you call a Context method the response will be directly send over the connection and you can send multiple responses. This function is useful when you want to keep the connection alive and/or send multiple responses. Like with the SSE.
fn (mut ctx Context) text(s string) Result
    Response with `s` as payload and content-type `text/plain`
fn (ctx &Context) user_agent() string
    user_agent returns the user-agent header for the current client
struct Controller {
pub mut:
	controllers []&ControllerPath
}
fn (mut c Controller) register_controller[A, X](path string, mut global_app A) !
    register_controller adds a new Controller to your app
fn (mut c Controller) register_host_controller[A, X](host string, path string, mut global_app A) !
    register_controller adds a new Controller to your app
struct ControllerPath {
pub:
	path    string
	handler ControllerHandler = unsafe { nil }
pub mut:
	host string
}
struct CorsOptions {
pub:
	// from which origin(s) can cross-origin requests be made; `Access-Control-Allow-Origin`
	origins []string @[required]
	// indicate whether the server allows credentials, e.g. cookies, in cross-origin requests.
	// ;`Access-Control-Allow-Credentials`
	allow_credentials bool
	// allowed HTTP headers for a cross-origin request; `Access-Control-Allow-Headers`
	allowed_headers []string = ['*']
	// allowed HTTP methods for a cross-origin request; `Access-Control-Allow-Methods`
	allowed_methods []http.Method
	// indicate if clients are able to access other headers than the "CORS-safelisted"
	// response headers; `Access-Control-Expose-Headers`
	expose_headers []string
	// how long the results of a preflight request can be cached, value is in seconds
	// ; `Access-Control-Max-Age`
	max_age ?int
}
    CorsOptions is used to set CORS response headers. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#the_http_response_headers
fn (options &CorsOptions) set_headers(mut ctx Context)
    set_headers adds the CORS headers on the response
fn (options &CorsOptions) validate_request(mut ctx Context) bool
    validate_request checks if a cross-origin request is made and verifies the CORS headers. If a cross-origin request is invalid this method will send a response using `ctx`.
struct Middleware[T] {
mut:
	global_handlers       []voidptr
	global_handlers_after []voidptr
	route_handlers        []RouteMiddleware
	route_handlers_after  []RouteMiddleware
}
struct MiddlewareOptions[T] {
pub:
	handler fn (mut ctx T) bool @[required]
	after   bool
}
struct RedirectParams {
pub:
	typ RedirectType
}
struct Result {}
    A dummy structure that returns from routes to indicate that you actually sent something to a user
struct RunParams {
pub:
	// use `family: .ip, host: 'localhost'` when you want it to bind only to 127.0.0.1
	family               net.AddrFamily = .ip6
	host                 string
	port                 int  = 8080
	show_startup_message bool = true
	timeout_in_seconds   int  = 30
}
struct StaticHandler {
pub mut:
	static_files      map[string]string
	static_mime_types map[string]string
	static_hosts      map[string]string
}
    StaticHandler provides methods to handle static files in your veb App
fn (mut sh StaticHandler) handle_static(directory_path string, root bool) !bool
    handle_static is used to mark a folder (relative to the current working folder) as one that contains only static resources (css files, images etc). If `root` is set the mount path for the dir will be in '/' Usage:
    ```v
    os.chdir( os.executable() )?
    app.handle_static('assets', true)
    ```
fn (mut sh StaticHandler) host_handle_static(host string, directory_path string, root bool) !bool
    host_handle_static is used to mark a folder (relative to the current working folder) as one that contains only static resources (css files, images etc). If `root` is set the mount path for the dir will be in '/' Usage:
    ```v
    os.chdir( os.executable() )?
    app.host_handle_static('localhost', 'assets', true)
    ```
fn (mut sh StaticHandler) mount_static_folder_at(directory_path string, mount_path string) !bool
    mount_static_folder_at - makes all static files in `directory_path` and inside it, available at http://server/mount_path For example: suppose you have called .mount_static_folder_at('/var/share/myassets', '/assets'), and you have a file /var/share/myassets/main.css . => That file will be available at URL: http://server/assets/main.css .
fn (mut sh StaticHandler) host_mount_static_folder_at(host string, directory_path string, mount_path string) !bool
    host_mount_static_folder_at - makes all static files in `directory_path` and inside it, available at http://host/mount_path For example: suppose you have called .host_mount_static_folder_at('localhost', '/var/share/myassets', '/assets'), and you have a file /var/share/myassets/main.css . => That file will be available at URL: http://localhost/assets/main.css .
fn (mut sh StaticHandler) serve_static(url string, file_path string) !
    Serves a file static `url` is the access path on the site, `file_path` is the real path to the file, `mime_type` is the file type
fn (mut sh StaticHandler) host_serve_static(host string, url string, file_path string) !
    Serves a file static `url` is the access path on the site, `file_path` is the real path to the file `host` is the host to serve the file from


## module veb.oauth

enum TokenPostType {
	form
	json
}
struct Context {
pub:
	token_url       string
	client_id       string
	client_secret   string
	token_post_type TokenPostType = .form
	redirect_uri    string
}
fn (ctx &Context) get_token(code string) string
struct Request {
pub:
	client_id     string
	client_secret string
	code          string
	state         string
}
