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
	images_created := ai_cli.create_image(op.ImageCreateArgs{
		prompt: "Calm weather",
		num_images: 2,
		size: op.ImageSize.size_512_512,
		format: op.ImageRespType.url,
	}
	)!
	print(images_created)
	images_updated := ai_cli.create_edit_image(op.ImageEditArgs{
		image_path: "/path/to/image.png",
		mask_path: "/path/to/mask.png",
		prompt: "Calm weather",
		num_images: 2,
		size: op.ImageSize.size_512_512,
		format: op.ImageRespType.url,
	}
	)!
	print(images_updated)
	images_variatons := ai_cli.create_variation_image(op.ImageVariationArgs{
		image_path: "/path/to/image.png",
		num_images: 2,
		size: op.ImageSize.size_512_512,
		format: op.ImageRespType.url,
	}
	)!
	print(images_variatons)

	transcription := ai_cli.create_transcription(
		op.AudioArgs{
			filepath: "/path/to/voice.wav",
		}
	)!
	print(transcription)

	transcription := ai_cli.create_tranlation(
		op.AudioArgs{
			filepath: "/path/to/voice.wav",
		}
	)!
	print(transcription)
}

