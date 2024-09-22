package ecs

import "core:os"
import "core:thread"

World :: struct {
	entities:         [dynamic]Entity,
	components:       ComponentStorage,
	systems:          [dynamic]System,
	parallel_systems: [dynamic]System,
	pool:             ^thread.Pool,
}

new_world :: proc() -> World {
	pool := new(thread.Pool)
	thread.pool_init(pool, context.allocator, os.processor_core_count())
	thread.pool_start(pool)

	return World {
		entities = make([dynamic]Entity),
		components = make(ComponentStorage),
		systems = make([dynamic]System),
		pool = pool,
	}
}

update :: proc(world: ^World) {
	run_systems(world)
	run_parallel_systems(world)
}
