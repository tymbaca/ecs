package ecs

import cmp "component"
import "core:os"
import "core:thread"
import "core:time"

World :: struct {
	entities:         [dynamic]Entity,
	components:       cmp.ComponentStorage,
	systems:          [dynamic]System,
	parallel_systems: [dynamic]System,
	pool:             ^thread.Pool,
	//
	prev_frame_time:  Maybe(time.Time),
	delta:            f32, // in secs
	delta_dur:        time.Duration,
}

new_world :: proc() -> World {
	pool := new(thread.Pool)
	thread.pool_init(pool, context.allocator, os.processor_core_count())
	thread.pool_start(pool)

	return World {
		entities = make([dynamic]Entity),
		components = make(cmp.ComponentStorage),
		systems = make([dynamic]System),
		pool = pool,
	}
}

update :: proc(world: ^World) {
	update_time(world)

	run_systems(world)
	run_parallel_systems(world)
}

update_time :: proc(world: ^World) {
	if world.prev_frame_time == nil {
		world.prev_frame_time = time.now()
	}

	delta_dur := time.since(world.prev_frame_time.(time.Time))
	world.delta_dur = delta_dur
	world.delta = f32(time.duration_seconds(delta_dur))
	world.prev_frame_time = time.now()
}
