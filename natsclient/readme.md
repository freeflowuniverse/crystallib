# NATSClient

This module implements a client that can connect with a [NATS](https://nats.io/) server, allowing a client to exchange messages with other clients through this server. The reader is recommended to go through the [documentation](https://docs.nats.io/) before continuing to read this document.

## Publishing and subscribing
NATS can shortly be defined as a publish-subscribe message system. A client can publish a message to a specific subject which other clients will receive if they subscribed to that subject. Subject hierarchy can be achieved by using the `.` character:
```
something.anotherthing.anotherone
```
The characters `*` (match anything from the same level in the hierarchy) and `>` (match anything in this level and levels down in the hierarchy) are wildcards when used in a subscription request. Subscriptions created with the subjects defined below will all receive messages published to `something.anotherthing.anotherone`.
```
something.*.anotherone
something.anotherthing.*
something.anotherthing.>
something.>
```

## Streams and Consumers
The [core NATS](https://docs.nats.io/nats-concepts/core-nats) does not guarantee 'at least once' service, meaning it does not guarantee that one of the clients received the message. Fortunately [JetStream](https://docs.nats.io/nats-concepts/jetstream) (a built-in distributed persistence system) does through the concept of streams and consumers. 

Streams are 'message stores', they define how the messages are stored (and many other things) at server side.

Consumers allow clients to consume messages and acknowledge the receipt of the messages, thus providing the 'at least once' service.

JetStream can also guarantee the 'at most once' service through a couple of API requests (and with help of its clients).

## NATSClient under the hood
The NATSClient class implements the [client protocol](https://docs.nats.io/reference/reference-protocols/nats-protocol#msg) allowing the client to publish and subscribe to subjects through a websocket. It can also create streams and consumers by publishing messages to system subjects. The payload of those messages should contain the configuration (json data) of each of the requests and can be found [here](https://github.com/nats-io/jsm.go/tree/main/schemas/jetstream/api/v1). NATS allows you to pass a reply subject when publishing the messages. NATS will use that subject to send responses to the client. 

### Under the hood: Pulling messages from a consumer
Messages can be pulled from a consumer by sending the following message:
```
PUB $JS.API.CONSUMER.MSG.NEXT.mystream.myconsumer myinbox 49\r\n{"expires":5000000000,"batch":20,"no_wait":false}\r\n
```
NATS will start consuming the messages from the consumer 'myconsumer' and will send them to the subject myinbox which the NATSClient has to subscribe to. The configuration tells NATS to:
- send batches of 20 messages
- make the pull request expire after 5 seconds (5000000000 nanoseconds)
- wait for messages until the pull request expires if there are no messages

### Under the hood: Acknowledging messages
In order to guarantee 'at most once' service NATS requires you to acknowledge messages. After sending a pull request NATS send the messages to the subject that was specified in the request (reply_to field). Those messages are formatted as shown [here](https://docs.nats.io/reference/reference-protocols/nats-protocol#msg). The class in nats_parser.v shows you how those messages can be parsed. The reply_to field in those messages will contain the system subject that should be used to acknowledge the message. It should be similar to `$JS.ACK.mystream.myconsumer.11.39.618.1674209322098595786.0`. You can then send the message shown below in order to acknowledge:
```
PUB $JS.ACK.mystream.myconsumer.11.39.618.1674209322098595786.0 0\r\n\r\n
```

### Settings
There are a lot of settings that can modify the behavior of NATS, the file nats_types.v contains some of them which we should still experiment with. For example:
- the time to wait before an acknowledgement is considered unsuccessful
- the amount of times NATS will send the message again after an unsuccessful acknowledgement
- whether we acknowledge all messages (default) or only the last of a batch which will acknowledge all of the messages before that
- etc.

## How to contribute
There is still a lot to experiment with:
- For now the messages are being acknowledged after receiving them. We might want to change that behavior. We could allow users of the NATSClient class to acknowledge them themselves. This could introduce only acknowledge messages when they have been fully processed by the user.
- We should experiment with the many settings provided by NATS
- We could either use redis or a channel to pass the received messages to the user of NATSClient. Redis would make it more persistent while a channel would be more performant. The choice will depend on the user of the NATSClient. Maybe we can provide both.
- Many of the publish messages in NATSClient do not use a reply_to subject, meaning NATS will not send a response on the request. We should experiment with the reply_to subject. This might help introducing failsafes (sending the acknowledgement again if it failed, etc).
- Testing the NATSClient