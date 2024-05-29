# Session Authentication

The session authentication module provides functionality for apps to keep, authenticate, and moderate user sessions. After a successful login, the session authenticator can be used to register session tokens to user id's. These session tokens can then be stored in client devices, verified by the session authenticator, and  used to implement user authentication and access control.

## Terminology

- Refresh token: long lived (default 30 days) session token kept by client. It can be used to generate access tokens or revoke users other refresh tokens.
- Access token: 
- signed token:
- decoded token:

## Authentication Flow

1. User registers to application with user data.
2. Application assigns user a unique user id
3. Application requests session authenticator (can be remote) to generate refresh token for the uuid.
4. Application requests session authenticator to generate access token from the refresh token.
5. Application stores refresh and access tokens on the client device.
6. User requests to view user data with access token (if token is expired user first generates a new access token)
7. Application requests session authenticator to verify access token
8. Application 

## Using `auth.session`

The session authentication module provides functionality for apps to keep, authenticate, and moderate user sessions. After a successful login, the session authenticator can be used to register session tokens to user id's. These session tokens can then be stored in client devices, verified by the session authenticator, and  used to implement user authentication and access control.

### Authenticator Keys

The Authenticator uses a secret key to sign and verify tokens. Both access and refresh tokens require a separate secret key. By default, the secret keys of the `Authenticator` is generated upon struct creation. For in memory applications this is sufficient, however applications storing user session tables in permanent memory should also store their secret keys safely in permanent ways, and create the authenticator with the correct keys.

## Registering User Session

The session authenticator identifies users from a unique string. This unique identifier is passed to the session authenticator when registering a user session. This allows the session authenticator to associate multiple session tokens with a unique identifier. As such separate mobile session and browser session tokens can persist and be used to authenticate the same unique identifier. This also allows for applications to revoke and thus invalidate multiple session tokens belonging to a unique identifier.

The session authenticator does not associate the unique identifier with a user, the implementation of that is decided by the application logic. The session authenticator solely verifies the association of an access token with a specific unique identifier, thus authenticating that the unique identifier belongs to the user possessing the token.

User sessions 

To use the vweb controller in the module, you need to create a `session.Controller` and add it to your vweb application as a controller. While it is not necessary, using `session.Client`, the client for the controller is recommended.

```

```

By doing so, you are able to run session controller endpoints in your vweb app, which embeds all of the essential session authentication functions into your application. You can then make client calls to interact with the session controller. The client is added to the application the following way