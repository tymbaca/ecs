package main

import ".."
import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:time"

main :: proc() {
	mm: map[int]map[int]int

	m := mm[0]
	m[4] = 5
	mm[0] = m

	fmt.println(mm)

	when true {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	w := ecs.new_world(Component)
	ecs.register_systems(&w, apply_velocity_system)

	for _ in 0 ..< 50 {
		ecs.update(&w)

		ecs.create_entity(&w, Position{0, 0}, Velocity{1, 2})

		fmt.println(w)
		time.sleep(100 * time.Millisecond)
	}
	/*
    */
}

apply_velocity_system :: proc(w: ^ecs.World(Component)) {
	for &e in w.entities {
		if ecs.has_components(e, Velocity, Position) {
			vel := ecs.must_get_component(w^, e.id, Velocity)
			pos := ecs.must_get_component(w^, e.id, Position)

			pos += Position(vel)

			ecs.set_component(w, &e, vel)
			ecs.set_component(w, &e, pos)
		}
	}
}

Component :: union {
	Position,
	Velocity,
}

Velocity :: distinct [2]f32

Position :: distinct [2]f32

log_types :: proc(Ts: ..typeid) {
	for t in Ts {
		fmt.println(t)
	}
}
