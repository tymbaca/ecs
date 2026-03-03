#+private
package ecs

import "core:math"
import "core:time"
import "core:debug/trace"
import "core:log"
import "core:testing"

Position :: distinct [2]f64
Velocity :: distinct [2]f64
Gravity :: struct {
	enabled: bool,
	force:   [2]f64,
}

@(test)
ecs_test :: proc(t: ^testing.T) {
	allocator := context.allocator

	world: World
	init(&world, {Position, Velocity, Gravity}, allocator)
	defer destroy(&world)

	w := &world

	register(&world, apply_velocity)
	register(&world, apply_gravity)

	e := create(w)
	set(w, e, Position{0, 0})
	set(w, e, Velocity{1, 1})
	set(w, e, Gravity{true, {0, -1}})

	e2 := create(w)
	set(w, e2, Position{11, 11})

	testing.expect(t, get(w, e, Position) == {0, 0})
	testing.expect(t, get(w, e, Velocity) == {1, 1})
	testing.expect(t, get(w, e, Gravity) == {true, {0, -1}})

	update(w)

	testing.expect(t, get(w, e, Position) == {1, 1})
	testing.expect(t, get(w, e, Velocity) == {1, 0})
	testing.expect(t, get(w, e, Gravity) == {true, {0, -1}})

	update(w)

	testing.expect(t, get(w, e, Position) == {2, 1})
	testing.expect(t, get(w, e, Velocity) == {1, -1})
	testing.expect(t, get(w, e, Gravity) == {true, {0, -1}})

	update(w)

	testing.expect(t, get(w, e, Position) == {3, 0})
	testing.expect(t, get(w, e, Velocity) == {1, -2})
	testing.expect(t, get(w, e, Gravity) == {true, {0, -1}})

	pos2, ok := get(w, e2, Position)
	testing.expect(t, ok)
	testing.expect(t, pos2 == {11, 11})

	_, ok = get(w, e2, Velocity)
	testing.expect(t, !ok)
	_, ok = get(w, e2, Gravity)
	testing.expect(t, !ok)
}

@(test)
ecs_stress_test :: proc(t: ^testing.T) {
	allocator := context.allocator

	world: World
	init(&world, {Position, Velocity, Gravity}, allocator)
	defer destroy(&world)

	w := &world

	register(&world, apply_velocity)
	register(&world, apply_gravity)

    start := time.tick_now()

    N1 :: 100_000
    reserve(w, N1)
	for _ in 0 ..< N1 {
		e := create(w)
		set(w, e, Position{0, 0})
		set(w, e, Velocity{1, 1})
		set(w, e, Gravity{true, {0, -1}})
	}

    log.info("create dur", time.tick_since(start))


    N2 :: 100
    frame_durs: [N2]time.Duration

    for i in 0 ..< N2 {
        frame_start := time.tick_now()
        update(w)
        frame_durs[i] = time.tick_since(frame_start)
    }

    avg_frame_dur := math.sum(frame_durs[:]) / N2
    log.info("avg frame dur", avg_frame_dur)

    log.info("total size", len(world.storage), "cap", cap(world.storage))
}

apply_velocity :: proc(w: ^World) {
	for entity in query(w, {Position, Velocity}) {
		pos := get(w, entity, Position)
		vel := get(w, entity, Velocity)

		pos += Position(vel)

		set(w, entity, pos)
	}
}

apply_gravity :: proc(w: ^World) {
	for entity in query(w, {Gravity, Velocity}) {
		grav := get(w, entity, Gravity)
		vel := get(w, entity, Velocity)

		if grav.enabled {
			vel += Velocity(grav.force)
		}

		set(w, entity, vel)
	}
}
