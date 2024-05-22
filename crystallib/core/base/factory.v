module base

__global (
	contexts        shared map[u32]&Context
	context_current shared u32
)
