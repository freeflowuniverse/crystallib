module dagu

pub struct ApiError {
	code int @[skip]
	message string @[required]
	detailed_message string @[required; json: 'detailedMessage']
}

fn (err ApiError) msg() string {
	return '${err.code} - ${err.message}\n${err.detailed_message}'
}

fn (err ApiError) code() int {
	return err.code
}
