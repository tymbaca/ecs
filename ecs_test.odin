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

/*
➜  ecs git:(main) odin test .
[INFO ] --- [2026-03-04 10:37:59] Starting test runner with 1 thread. Set with -define:ODIN_TEST_THREADS=n.
[INFO ] --- [2026-03-04 10:37:59] The random seed sent to every test is: 172294833546361. Set with -define:ODIN_TEST_RANDOM_SEED=n.
[INFO ] --- [2026-03-04 10:37:59] Memory tracking is enabled. Tests will log their memory usage if there's an issue.
[INFO ] --- [2026-03-04 10:37:59] < Final Mem/ Total Mem> <  Peak Mem> (#Free/Alloc) :: [package.test_name]
[INFO ] --- [2026-03-04 10:37:59] [ecs_test.odin:45:ecs_stress_test()] create dur 224.314ms
[INFO ] --- [2026-03-04 10:38:09] [ecs_test.odin:56:ecs_stress_test()] avg frame dur 95.945228ms
ecs  [|                       ]         1 :: [package done]

Finished 1 test in 9.819127s. The test was successful.

➜  ecs git:(main) odin test . -o:speed
[INFO ] --- [2026-03-04 10:38:20] Starting test runner with 1 thread. Set with -define:ODIN_TEST_THREADS=n.
[INFO ] --- [2026-03-04 10:38:20] The random seed sent to every test is: 172315970706209. Set with -define:ODIN_TEST_RANDOM_SEED=n.
[INFO ] --- [2026-03-04 10:38:20] Memory tracking is enabled. Tests will log their memory usage if there's an issue.
[INFO ] --- [2026-03-04 10:38:20] < Final Mem/ Total Mem> <  Peak Mem> (#Free/Alloc) :: [package.test_name]
[INFO ] --- [2026-03-04 10:38:20] [ecs_test.odin:45:ecs_stress_test()] create dur 57.517291ms
[INFO ] --- [2026-03-04 10:38:23] [ecs_test.odin:56:ecs_stress_test()] avg frame dur 29.721669ms
ecs  [|                       ]         1 :: [package done]

Finished 1 test in 3.029941s. The test was successful.
*/

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
    before_frames_start := time.tick_now()

    for i in 0 ..< N2 {
        update(w)
        // unset(w, {10, 999999}, Position)
    }

    avg_frame_dur := time.tick_since(before_frames_start) / N2
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
