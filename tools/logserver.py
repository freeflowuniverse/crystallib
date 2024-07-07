import socket
import os

# Path to the Unix socket
socket_path = "/tmp/example.sock"

# Ensure the socket does not already exist
try:
    os.unlink(socket_path)
except OSError:
    if os.path.exists(socket_path):
        raise

# Create a Unix socket
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# Bind the socket to the path
server.bind(socket_path)

# Listen for incoming connections
server.listen()

print("Listening on socket:", socket_path)

try:
    while True:
        # Accept a connection
        connection, client_address = server.accept()
        try:
            print('Connection from', client_address)

            # Receive the data in small chunks and print it
            while True:
                data = connection.recv(1024)
                if data:
                    print('Received:', data.decode())
                else:
                    print('No more data from', client_address)
                    break
        finally:
            # Clean up the connection
            connection.close()
finally:
    server.close()
    os.unlink(socket_path)
