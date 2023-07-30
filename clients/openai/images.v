module openai

import json

pub enum ImageSize {
	size_256_256
	size_512_512
	size_1024_1024
}

fn image_size_str(i ImageSize) string {
	return match i {
		.size_256_256 {
			"256x256"
		}
		.size_512_512 {
			"512x512"
		}
		.size_1024_1024 {
			"1024x1024"
		}
	}
}

pub enum ImageRespType {
	url
	b64_json
}

fn image_resp_type_str(i ImageRespType) string{
	return match i {
		.url {
			"url"
		}
		.b64_json {
			"b64_json"
		}
	}
}

pub struct ImageRequest {
pub mut:
	prompt string
	n int
	size string
	response_format string
}


pub struct ImageResponse {
pub mut:
	url string
	b64_json string
}

pub struct Images {
pub mut:
	created int
	data []ImageResponse
}

pub fn (mut f OpenAIFactory) create_image(
	prompt string,
	num_images int,
	size ImageSize,
	format ImageRespType
) !Images {
	image_size := image_size_str(size)
	response_format := image_resp_type_str(format)
	request := ImageRequest{
		prompt: prompt,
		n: num_images,
		size: image_size,
		response_format: response_format,
	}
	data := json.encode(request)
	r := f.connection.post_json_str(prefix: 'images/generations', data: data)!
	return json.decode(Images, r)!
}

