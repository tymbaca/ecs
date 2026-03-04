#+private
package ecs

import "base:runtime"
import "core:math"
import "core:time"
import "core:log"
import "core:testing"

Component :: union {
    Position,
    Velocity,
    Gravity,
}

Position :: distinct [2]f64
Velocity :: distinct [2]f64
Gravity :: struct {
	enabled: bool,
	force:   [2]f64,
}

@(test)
ecs_stress_test :: proc(t: ^testing.T) {
    context.allocator = runtime.heap_allocator()

	world := new_world(Component)
	register_systems(&world, apply_velocity, apply_gravity)

	w := &world

    start := time.tick_now()

    N1 :: 100_000
    // reserve(w, N1)
	for _ in 0 ..< N1 {
		e := create_entity(w, 
            Position{0, 0},
            Velocity{1, 1},
            Gravity{true, {0, -1}},
        )
        _ = e
	}

    log.info("create dur", time.tick_since(start))

    N2 :: 100
    frame_durs: [N2]time.Duration

    for i in 0 ..< N2 {
        update(w)
        // unset(w, {10, 999999}, Position)
    }

    avg_frame_dur := math.sum(frame_durs[:]) / N2
    log.info("avg frame dur", avg_frame_dur)

    // log.info("total size", len(world.storage), "cap", cap(world.storage))

	// for id in 0 ..< N1 {
	// 	kill(w, {id = id, generation = 9999999})
	// }
	//
	// for _ in 0 ..< N1 {
	// 	_ = create(w)
	// }

    // testing.expect_value(t, w.next_id, N1)
}

apply_velocity :: proc(w: ^World(Component)) {
	for &e in w.entities {
		if has_components(e, Velocity, Position) {
			vel := must_get_component(w^, e.id, Velocity)
			pos := must_get_component(w^, e.id, Position)

			pos += Position(vel)

			set_component(w, &e, pos)
		}
	}
}

apply_gravity :: proc(w: ^World(Component)) {
	for &e in w.entities {
		if has_components(e, Velocity, Gravity) {
			grav := must_get_component(w^, e.id, Gravity)
			vel := must_get_component(w^, e.id, Velocity)

            if grav.enabled {
                vel += Velocity(grav.force)
            }

			set_component(w, &e, vel)
		}
	}
}
