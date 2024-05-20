module base

__global (
	contexts shared map[u32]&Context
	//sessions shared map[u32]&Session
	context_current shared u32
)

