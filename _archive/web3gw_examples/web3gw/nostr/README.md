# Nostr examples

## Publish and subscribe to messages

To run the pubsub example

(secret is optional)

```sh
v -cg run pubsub.v -s b4fc308f04cb3dc80c2caf18dadc42ba4a7dbdbc1471a2e40fa091ac0e96d711
```

## Chat

To run the chat example, open 2 terminal windows. In one window run the consumer (this will start streaming for direct messages on a nostr relay):

Use following secret (b4fc308f04cb3dc80c2caf18dadc42ba4a7dbdbc1471a2e40fa091ac0e96d711) or generate your own

```sh
v -cg run main_nostr_chat_consumer.v -s b4fc308f04cb3dc80c2caf18dadc42ba4a7dbdbc1471a2e40fa091ac0e96d711
```

In a second pane, run the publisher:

Receiver: (2bd6ab7f8a9c8c1a337611786aa06a8ab9be0a03bd0ab9417d190109be9cc9a7)
Secret: (fb2184cac1bfa5694977d289b698afefc1d012d978e72de6b433dba1cd54ec3d)

```sh
 v -cg run main_nostr_chat_publisher.v -r 2bd6ab7f8a9c8c1a337611786aa06a8ab9be0a03bd0ab9417d190109be9cc9a7 -s fb2184cac1bfa5694977d289b698afefc1d012d978e72de6b433dba1cd54ec3d
```

You should now see a message in the consumer pane.