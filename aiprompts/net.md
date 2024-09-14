module net
    ## Description
    
    `net` provides networking functions. It is mostly a wrapper to BSD sockets, so you can listen on a port, connect to remote TCP/UDP services, and communicate with them.

const msg_nosignal = 0x4000
const err_connection_refused = error_with_code('net: connection refused', errors_base + 10)
const err_option_wrong_type = error_with_code('net: set_option_xxx option wrong type',
	errors_base + 3)
const opts_can_set = [
	SocketOption.broadcast,
	.debug,
	.dont_route,
	.keep_alive,
	.linger,
	.oob_inline,
	.receive_buf_size,
	.receive_low_size,
	.receive_timeout,
	.send_buf_size,
	.send_low_size,
	.send_timeout,
	.ipv6_only,
]
const error_eagain = C.EAGAIN
const err_port_out_of_range = error_with_code('net: port out of range', errors_base + 5)
const opts_bool = [SocketOption.broadcast, .debug, .dont_route, .error, .keep_alive, .oob_inline]
const err_connect_failed = error_with_code('net: connect failed', errors_base + 7)
const errors_base = 0
    Well defined errors that are returned from socket functions
const opts_int = [
	SocketOption.receive_buf_size,
	.receive_low_size,
	.receive_timeout,
	.send_buf_size,
	.send_low_size,
	.send_timeout,
]
const error_eintr = C.EINTR
const error_ewouldblock = C.EWOULDBLOCK
const err_no_udp_remote = error_with_code('net: no udp remote', errors_base + 6)
const error_einprogress = C.EINPROGRESS
const err_timed_out_code = errors_base + 9
const err_connect_timed_out = error_with_code('net: connect timed out', errors_base + 8)
const err_new_socket_failed = error_with_code('net: new_socket failed to create socket',
	errors_base + 1)
const msg_dontwait = C.MSG_DONTWAIT
const infinite_timeout = time.infinite
    infinite_timeout should be given to functions when an infinite_timeout is wanted (i.e. functions only ever return with data)
const no_timeout = time.Duration(0)
    no_timeout should be given to functions when no timeout is wanted (i.e. all functions return instantly)
const err_timed_out = error_with_code('net: op timed out', errors_base + 9)
const tcp_default_read_timeout = 30 * time.second
const err_option_not_settable = error_with_code('net: set_option_xxx option not settable',
	errors_base + 2)
const tcp_default_write_timeout = 30 * time.second
fn addr_from_socket_handle(handle int) Addr
    addr_from_socket_handle returns an address, based on the given integer socket `handle`
fn close(handle int) !
    close a socket, given its file descriptor `handle`. In non-blocking mode, if `close()` does not succeed immediately, it causes an error to be propagated to `TcpSocket.close()`, which is not intended. Therefore, `select` is used just like `connect()`.
fn default_tcp_dialer() Dialer
    default_tcp_dialer will give you an instance of Dialer, that is suitable for making new tcp connections.
fn dial_tcp(oaddress string) !&TcpConn
    dial_tcp will try to create a new TcpConn to the given address.
fn dial_tcp_with_bind(saddr string, laddr string) !&TcpConn
    dial_tcp_with_bind will bind the given local address `laddr` and dial.
fn dial_udp(raddr string) !&UdpConn
fn error_code() int
fn listen_tcp(family AddrFamily, saddr string, options ListenOptions) !&TcpListener
fn listen_udp(laddr string) !&UdpConn
fn new_ip(port u16, addr [4]u8) Addr
    new_ip creates a new Addr from the IPv4 address family, based on the given port and addr
fn new_ip6(port u16, addr [16]u8) Addr
    new_ip6 creates a new Addr from the IP6 address family, based on the given port and addr
fn peer_addr_from_socket_handle(handle int) !Addr
    peer_addr_from_socket_handle retrieves the ip address and port number, given a socket handle
fn resolve_addrs(addr string, family AddrFamily, @type SocketType) ![]Addr
    resolve_addrs converts the given `addr`, `family` and `@type` to a list of addresses
fn resolve_addrs_fuzzy(addr string, @type SocketType) ![]Addr
    resolve_addrs converts the given `addr` and `@type` to a list of addresses
fn resolve_ipaddrs(addr string, family AddrFamily, typ SocketType) ![]Addr
    resolve_ipaddrs converts the given `addr`, `family` and `typ` to a list of addresses
fn set_blocking(handle int, state bool) !
    set_blocking will change the state of the socket to either blocking, when state is true, or non blocking (false).
fn shutdown(handle int, config ShutdownConfig) int
    shutdown shutsdown a socket, given its file descriptor `handle`. By default it shuts it down in both directions, both for reading and for writing. You can change that using `net.shutdown(handle, how: .read)` or `net.shutdown(handle, how: .write)` In non-blocking mode, `shutdown()` may not succeed immediately, so `select` is also used to make sure that the function doesn't return an incorrect result.
fn socket_error(potential_code int) !int
fn socket_error_message(potential_code int, s string) !int
fn split_address(addr string) !(string, u16)
    split_address splits an address into its host name and its port
fn tcp_socket_from_handle_raw(sockfd int) TcpSocket
    tcp_socket_from_handle_raw is similar to tcp_socket_from_handle, but it does not modify any socket options
fn validate_port(port int) !u16
    validate_port checks whether a port is valid and returns the port or an error
fn wrap_error(error_code int) !
interface Connection {
	addr() !Addr
	peer_addr() !Addr
mut:
	read(mut []u8) !int
	write([]u8) !int
	close() !
}
    Connection provides a generic SOCK_STREAM style interface that protocols can use as a base connection object to support TCP, UNIX Domain Sockets and various proxying solutions.
interface Dialer {
	dial(address string) !Connection
}
    Dialer is an abstract dialer interface for producing connections to adresses.
fn (mut s TcpSocket) set_option_bool(opt SocketOption, value bool) !
fn (mut s TcpSocket) set_option_int(opt SocketOption, value int) !
fn (mut s TcpSocket) set_dualstack(on bool) !
fn (mut s TcpSocket) bind(addr string) !
    bind a local rddress for TcpSocket
fn (mut s UdpSocket) set_option_bool(opt SocketOption, value bool) !
fn (mut s UdpSocket) set_dualstack(on bool) !
enum AddrFamily {
	unix   = C.AF_UNIX
	ip     = C.AF_INET
	ip6    = C.AF_INET6
	unspec = C.AF_UNSPEC
}
    AddrFamily are the available address families
enum ShutdownDirection {
	read
	write
	read_and_write
}
    ShutdownDirection is used by `net.shutdown`, for specifying the direction for which the communication will be cut.
enum SocketOption {
	// TODO: SO_ACCEPT_CONN is not here because windows doesn't support it
	// and there is no easy way to define it
	broadcast        = C.SO_BROADCAST
	debug            = C.SO_DEBUG
	dont_route       = C.SO_DONTROUTE
	error            = C.SO_ERROR
	keep_alive       = C.SO_KEEPALIVE
	linger           = C.SO_LINGER
	oob_inline       = C.SO_OOBINLINE
	reuse_addr       = C.SO_REUSEADDR
	receive_buf_size = C.SO_RCVBUF
	receive_low_size = C.SO_RCVLOWAT
	receive_timeout  = C.SO_RCVTIMEO
	send_buf_size    = C.SO_SNDBUF
	send_low_size    = C.SO_SNDLOWAT
	send_timeout     = C.SO_SNDTIMEO
	socket_type      = C.SO_TYPE
	ipv6_only        = C.IPV6_V6ONLY
}
enum SocketType {
	udp       = C.SOCK_DGRAM
	tcp       = C.SOCK_STREAM
	seqpacket = C.SOCK_SEQPACKET
}
    SocketType are the available sockets
struct Addr {
pub:
	len  u8
	f    u8
	addr AddrData
}
fn (a Addr) family() AddrFamily
    family returns the family/kind of the given address `a`
fn (a Addr) len() u32
    len returns the length in bytes of the address `a`, depending on its family
fn (a Addr) port() !u16
    port returns the ip or ip6 port of the given address `a`
fn (a Addr) str() string
    str returns a string representation of the address `a`
struct C.addrinfo {
mut:
	ai_family    int
	ai_socktype  int
	ai_flags     int
	ai_protocol  int
	ai_addrlen   int
	ai_addr      voidptr
	ai_canonname voidptr
	ai_next      voidptr
}
struct C.fd_set {}
struct C.sockaddr_in {
mut:
	sin_len    u8
	sin_family u8
	sin_port   u16
	sin_addr   u32
	sin_zero   [8]char
}
struct C.sockaddr_in6 {
mut:
	// 1 + 1 + 2 + 4 + 16 + 4 = 28;
	sin6_len      u8     // 1
	sin6_family   u8     // 1
	sin6_port     u16    // 2
	sin6_flowinfo u32    // 4
	sin6_addr     [16]u8 // 16
	sin6_scope_id u32    // 4
}
struct C.sockaddr_un {
mut:
	sun_len    u8
	sun_family u8
	sun_path   [max_unix_path]char
}
struct Ip {
	port u16
	addr [4]u8
	// Pad to size so that socket functions
	// dont complain to us (see  in.h and bind())
	// TODO(emily): I would really like to use
	// some constant calculations here
	// so that this doesnt have to be hardcoded
	sin_pad [8]u8
}
fn (a Ip) str() string
    str returns a string representation of `a`
struct Ip6 {
	port      u16
	flow_info u32
	addr      [16]u8
	scope_id  u32
}
fn (a Ip6) str() string
    str returns a string representation of `a`
struct ListenOptions {
pub:
	dualstack bool = true
	backlog   int  = 128
}
struct ShutdownConfig {
pub:
	how ShutdownDirection = .read_and_write
}
struct Socket {
pub:
	handle int
}
fn (s &Socket) address() !Addr
    address gets the address of a socket
struct TCPDialer {}
    TCPDialer is a concrete instance of the Dialer interface, for creating tcp connections.
fn (t TCPDialer) dial(address string) !Connection
    dial will try to create a new abstract connection to the given address. It will return an error, if that is not possible.
struct TcpConn {
pub mut:
	sock           TcpSocket
	handle         int
	write_deadline time.Time
	read_deadline  time.Time
	read_timeout   time.Duration
	write_timeout  time.Duration
	is_blocking    bool = true
}
fn (c &TcpConn) addr() !Addr
fn (mut c TcpConn) close() !
    close closes the tcp connection
fn (mut con TcpConn) get_blocking() bool
    get_blocking returns whether the connection is in a blocking state, that is calls to .read_line, C.recv etc will block till there is new data arrived, instead of returning immediately.
fn (c &TcpConn) peer_addr() !Addr
    peer_addr retrieves the ip address and port number used by the peer
fn (c &TcpConn) peer_ip() !string
    peer_ip retrieves the ip address used by the peer, and returns it as a string
fn (c TcpConn) read(mut buf []u8) !int
    read reads data from the tcp connection into the mutable buffer `buf`. The number of bytes read is limited to the length of the buffer `buf.len`. The returned value is the number of read bytes (between 0 and `buf.len`).
fn (mut c TcpConn) read_deadline() !time.Time
fn (mut con TcpConn) read_line() string
    read_line is a *simple*, *non customizable*, blocking line reader. It will return a line, ending with LF, or just '', on EOF.
    
    Note: if you want more control over the buffer, please use a buffered IO reader instead: `io.new_buffered_reader({reader: io.make_reader(con)})`
fn (mut con TcpConn) read_line_max(max_line_len int) string
    read_line_max is a *simple*, *non customizable*, blocking line reader. It will return a line, ending with LF, '' on EOF. It stops reading, when the result line length exceeds max_line_len.
fn (c TcpConn) read_ptr(buf_ptr &u8, len int) !int
    read_ptr reads data from the tcp connection to the given buffer. It reads at most `len` bytes. It returns the number of actually read bytes, which can vary between 0 to `len`.
fn (c &TcpConn) read_timeout() time.Duration
fn (mut con TcpConn) set_blocking(state bool) !
    set_blocking will change the state of the connection to either blocking, when state is true, or non blocking (false). The default for `net` tcp connections is the blocking mode. Calling .read_line will set the connection to blocking mode. In general, changing the blocking mode after a successful connection may cause unexpected surprises, so this function is not recommended to be called anywhere but for this file.
fn (mut c TcpConn) set_read_deadline(deadline time.Time)
fn (mut c TcpConn) set_read_timeout(t time.Duration)
fn (mut c TcpConn) set_sock() !
    set_sock initialises the c.sock field. It should be called after `.accept_only()!`.
    
    Note: just use `.accept()!`. In most cases it is simpler, and calls `.set_sock()!` for you.
fn (mut c TcpConn) set_write_deadline(deadline time.Time)
fn (mut c TcpConn) set_write_timeout(t time.Duration)
fn (c TcpConn) str() string
fn (c TcpConn) wait_for_read() !
fn (mut c TcpConn) wait_for_write() !
fn (mut c TcpConn) write(bytes []u8) !int
    write blocks and attempts to write all data
fn (mut c TcpConn) write_deadline() !time.Time
fn (mut c TcpConn) write_ptr(b &u8, len int) !int
    write_ptr blocks and attempts to write all data
fn (mut c TcpConn) write_string(s string) !int
    write_string blocks and attempts to write all data
fn (c &TcpConn) write_timeout() time.Duration
struct TcpListener {
pub mut:
	sock            TcpSocket
	accept_timeout  time.Duration
	accept_deadline time.Time
	is_blocking     bool = true
}
fn (mut l TcpListener) accept() !&TcpConn
    accept a tcp connection from an external source to the listener `l`.
fn (mut l TcpListener) accept_only() !&TcpConn
    accept_only accepts a tcp connection from an external source to the listener `l`. Unlike `accept`, `accept_only` *will not call* `.set_sock()!` on the result, and is thus faster.
    
    
    
    Note: you *need* to call `.set_sock()!` manually, before using theconnection after calling `.accept_only()!`, but that does not have to happen in the same thread that called `.accept_only()!`. The intention of this API, is to have a more efficient way to accept connections, that are later processed by a thread pool, while the main thread remains active, so that it can accept other connections. See also vlib/vweb/vweb.v .
    
    If you do not need that, just call `.accept()!` instead, which will call `.set_sock()!` for you.
fn (c &TcpListener) accept_deadline() !time.Time
fn (mut c TcpListener) set_accept_deadline(deadline time.Time)
fn (c &TcpListener) accept_timeout() time.Duration
fn (mut c TcpListener) set_accept_timeout(t time.Duration)
fn (mut c TcpListener) wait_for_accept() !
fn (mut c TcpListener) close() !
fn (c &TcpListener) addr() !Addr
struct UdpConn {
pub mut:
	sock UdpSocket
mut:
	write_deadline time.Time
	read_deadline  time.Time
	read_timeout   time.Duration
	write_timeout  time.Duration
}
fn (mut c UdpConn) write_ptr(b &u8, len int) !int
    sock := UdpSocket{ handle: sbase.handle l: local r: resolve_wrapper(raddr) } }
fn (mut c UdpConn) write(buf []u8) !int
fn (mut c UdpConn) write_string(s string) !int
fn (mut c UdpConn) write_to_ptr(addr Addr, b &u8, len int) !int
fn (mut c UdpConn) write_to(addr Addr, buf []u8) !int
    write_to blocks and writes the buf to the remote addr specified
fn (mut c UdpConn) write_to_string(addr Addr, s string) !int
    write_to_string blocks and writes the buf to the remote addr specified
fn (mut c UdpConn) read(mut buf []u8) !(int, Addr)
    read reads from the socket into buf up to buf.len returning the number of bytes read
fn (c &UdpConn) read_deadline() !time.Time
fn (mut c UdpConn) set_read_deadline(deadline time.Time)
fn (c &UdpConn) write_deadline() !time.Time
fn (mut c UdpConn) set_write_deadline(deadline time.Time)
fn (c &UdpConn) read_timeout() time.Duration
fn (mut c UdpConn) set_read_timeout(t time.Duration)
fn (c &UdpConn) write_timeout() time.Duration
fn (mut c UdpConn) set_write_timeout(t time.Duration)
fn (mut c UdpConn) wait_for_read() !
fn (mut c UdpConn) wait_for_write() !
fn (c &UdpConn) str() string
fn (mut c UdpConn) close() !
struct Unix {
	path [max_unix_path]char
}
