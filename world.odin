package ecs

import "base:intrinsics"
import "core:os"
import "core:thread"
import "core:time"
import "core:fmt"

World :: struct($T: typeid) {
	entities:            [dynamic]Entity,
	components:          map[typeid]map[int]T,
	systems_collections: map[string]System_Collection(T),
	parallel_systems:    [dynamic]Parallel_System,
	pool:                ^thread.Pool,
	//
	prev_frame_time:     Maybe(time.Time),
	delta:               f32, // in secs
	delta_dur:           time.Duration,
}

new_world :: proc($T: typeid) -> World(T) where intrinsics.type_is_union(T) {
	pool := new(thread.Pool)
	thread.pool_init(pool, context.allocator, os.processor_core_count())
	thread.pool_start(pool)

	return World(T) {
		entities = make([dynamic]Entity),
		components = make(map[typeid]map[int]T),
		systems_collections = make(map[string]System_Collection(T)),
		pool = pool,
	}
}

update :: proc(world: ^World($T)) {
	update_time(world)

	for _, collection in world.systems_collections {
        fmt.println("updating collection:", collection)
		for system in collection.systems {
			system(world)
		}
	}
	run_parallel_systems(world)
}

// `update_collection` only updates the specified collection of systems, without 
// updating the time info. In order to update the time call `update_time` directrly
update_collection :: proc(world: ^World($T), collection: string) {
	collection_ := world.systems_collections[collection]
	for system in collection_.systems {
		system(world)
	}
}

// `update_time` must be called only once per frame
update_time :: proc(world: ^World($T)) {
	if world.prev_frame_time == nil {
		world.prev_frame_time = time.now()
	}

	delta_dur := time.since(world.prev_frame_time.(time.Time))
	world.delta_dur = delta_dur
	world.delta = f32(time.duration_seconds(delta_dur))
	world.prev_frame_time = time.now()
}
