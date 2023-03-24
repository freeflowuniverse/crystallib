spawn:

- processor
- telegramclient
- flowsupervisor

guest -> tbot -> tclient(through telegram)
tclient -> ui.telegram.forward
ui.telegram.forward -> flow_supervisor
if chat_id initializes new flow
    flow_supervisor creates newflow
    flow_supervisor -> newflow
else if chat_id in existing flow
    flow_supervisor -> existingflow

flow parses message and creates response
flow -> ui.telegram.out
ui.telegram.out -> tclient -> tbot -> guest

Questions:
- is flow_supervisor telegram specific?
  - if not then shouldn't the telegram client parse the update into a standard format ie action, params

Flow Supervisor:
- receives messages requesting new flows
- forwards messages into existing flows

Entities:
- TelegramClient
  - receives messages from users and sends them to FlowSupervisor
  - receives messages from UIChannels and send them to users
- Processor
  - acts as messaging bus
- FlowSupervisor - agnostic
  - receives messages from TelegramClient and creates flows
- Flows - agnostic
  - receives messages from FlowSupervisor and 
- UIChannels
- Questions


# New Plan

struct TelegramClient {
  
}

Contents
- 1 processor
- 1 actionrunner
- 1 telegram client
- 1 actor
  - many flows
  - many questions
  - flow supervisor