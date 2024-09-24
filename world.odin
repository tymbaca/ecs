package ecs

import "base:intrinsics"
import "core:os"
import "core:thread"

World :: struct($T: typeid) {
	entities:         [dynamic]Entity,
	components:       map[typeid]map[int]T,
	systems:          [dynamic]proc(world: ^World(T)),
	parallel_systems: [dynamic]Parallel_System,
	pool:             ^thread.Pool,
}

new_world :: proc($T: typeid) -> World(T) where intrinsics.type_is_union(T) {
	pool := new(thread.Pool)
	thread.pool_init(pool, context.allocator, os.processor_core_count())
	thread.pool_start(pool)

	return World(T) {
		entities = make([dynamic]Entity),
		components = make(map[typeid]map[int]T),
		systems = make([dynamic]proc(_: ^World(T))),
		pool = pool,
	}
}

update :: proc(world: ^World($T)) {
	run_systems(world)
	run_parallel_systems(world)
}
