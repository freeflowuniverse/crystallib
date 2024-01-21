# Channels Example

The channels example exposes the following functionality:

- Listing all public channels in a relay
- Reading all messages sent to a channel
- Sending a message to a channel, with the ability to mark the message as a reply for another message/user.
- Subscribing to a channel.
- Creating a new channel
  
## CLI Arguments

The [channels cli](../../../../examples/nostr/channels.v) has the following arguments:

- secret: this is your secret for nostr. if none was provided, a new secret will be generated, used, and printed out to terminal.
- realy_url: this is the relay URL to connect to. this defaults to `https://nostr01.grid.tf/`
- operation: this is the operation that you want to perform. must be one of `list`, `read`, or `send`.

### List Operation Arguments

There are no extra arguments for the list operation.

```sh
    v run channels.v -s "YOUR SECRET" -o list
```

### Read Operation Arguments

- channel: this is the Channel ID to read messages from. a Channel ID is the event ID of the channel creation event.

```sh
    v run channels.v -s "YOUR SECRET" -o read  "CHANNEL ID"
```

### Send Operation Arguments

- channel: this is the Channel ID to send the message to. a Channel ID is the event ID of the channel creation event.
- content: this is the content of the message.
- reply_to: this is the message ID to reply to, if any.
- public_key_author: this is the public key of the author of the message that you want to reply to, if any.

```sh
    v run channels.v -s "YOUR SECRET" -o send "CHANNEL ID" "Message content" -reply_to "MESSAGE ID TO REPLY TO"
```

### Subscribe Operation Arguments

- channel_id: this is the Channel ID to subscribe to. a Channel ID is the event ID of the channel creation event.

```sh
    v run channels.v -s "YOUR SECRET" -o subscribe "CHANNEL ID"
```

### Create Operation Arguments

- name: New channel name.
- description: Channel description.
- picture: Picture URL for the channel.

```sh
    v run channels.v -s "YOUR SECRET" -o create my_new_channel_name -d "my channel description" -p "https://www.my_channel_picture_url.com
```
