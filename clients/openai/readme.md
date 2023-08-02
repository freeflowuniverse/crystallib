# OpenAI

An implementation of an OpenAI client using Vlang.

## Supported methods

- List available models
- Chat Completion
- Translate Audio
- Transcribe Audio
- Create image based on prompt
- Edit an existing image
- Create variation of an image

## Usage

To use the client you need a OpenAi key which can be generated from [here](https://platform.openai.com/account/api-keys).

The key should be exposed in an environment variable as following:

```bash
export OPENAI_API_KEY=<your-api-key>
```

To get a new instance of the client:

```v
import freeflowuniverse.crystallib.clients.openai

ai_cli := openai.new()!
```

Then it is possible to perform all the listed operations:

```v
// listing models
models := ai_cli.list_models()!

// creating a new chat completion

mut msg := []op.Message{}
msg << op.Message{
    role: op.RoleType.user
    content: 'Say this is a test!'
}
mut msgs := op.Messages{
    messages: msg
}
res := ai_cli.chat_completion(op.ModelType.gpt_3_5_turbo, msgs)!
```
