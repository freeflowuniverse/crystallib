## HTTP Module README

### Overview

The `http` module is a robust and production-ready HTTP server wrapper for the Caddy HTTP module. This module simplifies the creation and management of HTTP servers, routes, reverse proxies, file servers, and basic authentication. By default, HTTPS is enabled if the host matchers with qualifying names are used in any routes, with automatic certificate provisioning and renewal.

### Features

- **Easily Model and Configure Caddy HTTP**: Simplifies the process of setting up and managing Caddy HTTP servers, routes, reverse proxies, file servers, and basic authentication using V programming language.
- **Route Management**: Add and manage HTTP routes effortlessly with predefined structures and handlers.
- **Reverse Proxy Configuration**: Simplify the configuration of reverse proxies with intuitive function calls.
- **File Server Setup**: Quickly set up file servers with defined domains and root directories.
- **Basic Authentication Integration**: Implement basic authentication for specific routes seamlessly.
- **Helper Functions**: Provides utility functions like password hashing to enhance security and ease of use.

### Usage

#### Adding a Route

To add a new route to the server:

```v
mut h := http.HTTP{}
h.add_route('/example', [http.Handle{handler: 'exampleHandler'}])!
```

#### Adding a File Server

To add a file server:

```v
file_server_args := http.FileServer{
	domain: 'example.com',
	root: '/var/www/html'
}
h.add_file_server(file_server_args)!
```

#### Adding a Reverse Proxy

To add a reverse proxy:

```v
reverse_proxy_args := http.ReverseProxy{
	from: '/proxy',
	to: 'http://backend.server'
}
h.add_reverse_proxy(reverse_proxy_args)!
```

#### Adding Basic Authentication

To add basic authentication to all routes for a specific domain:

```v
basic_auth_args := http.BasicAuth{
	domain: 'example.com',
	username: 'user',
	password: 'password'
}
h.add_basic_auth(basic_auth_args)!
```

### Handles

Handles are used to define the actions to be performed for each route. The following handles are available:

- **`authenticator_handle`**: Handles authentication using a specified portal.
- **`authentication_handle`**: Manages authentication policies.
- **`reverse_proxy_handle`**: Configures reverse proxy settings.
- **`basic_auth_handle`**: Sets up basic HTTP authentication.

#### Example of Using Handles

```v
// Define a reverse proxy handle
rp_handle := http.reverse_proxy_handle(['http://backend1', 'http://backend2'])

// Use the handle in a route
mut h := http.HTTP{}
h.add_route('/proxy', [rp_handle])!
```

### Merging HTTP Configurations

The `http` module provides functionality to merge two `HTTP` configurations into one. This allows you to combine multiple server configurations seamlessly. When merging, the function:

- **Combines Servers**: If servers from both configurations share the same key, they are merged; otherwise, the server from the second configuration is added.
- **Merges Listening Ports**: Ensures all unique listening ports from both servers are included.
- **Merges Routes**: Adds routes from the second server only if the host hasn't been defined in the first server's routes.

Here's an example of how to use the merge functionality:

```v
import http

http1 := http.HTTP{...}
http2 := http.HTTP{...}

merged_http := http.merge_http(http1, http2)
```

This is useful for merging different caddy configurations.