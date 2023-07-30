module main
import freeflowuniverse.crystallib.clients.openai as op

fn main() {
	mut ai_cli := op.new()!
	mut msg := []op.Message{}
	msg << op.Message{role: op.RoleType.user, content: "Say this is a test!"}
	mut msgs := op.Messages{messages: msg}
	res := ai_cli.chat_completion(op.ModelType.gpt_3_5_turbo, msgs)!
	print(res)

	models := ai_cli.list_models()!

	model := ai_cli.get_model(models.data[0].id)!
	print(model)
	images := ai_cli.create_image(
		"Calm weather",
		2,
		op.ImageSize.size_512_512,
		op.ImageRespType.url,
	)!
	print(images)
}

