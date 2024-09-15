import asynchttpserver, asyncdispatch

proc handleRequest(req: Request) {.async.} =
  if req.reqMethod == HttpGet:
    await req.respond(Http200, "Hello, World!")
  else:
    await req.respond(Http405, "Method not allowed")

proc main() {.async.} =
  var server = newAsyncHttpServer()
  server.listen(Port(8099))
  echo "Server listening on http://localhost:8080"
  
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(handleRequest)
    else:
      await sleepAsync(500)

waitFor main()