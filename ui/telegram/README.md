spawn:

- processor
- telegramclient
- flowsupervisor

guest -> tbot (restaurant)
tbot -> flow_supervisor (init rest_flow)
restaurant_flow -> tbot ()
