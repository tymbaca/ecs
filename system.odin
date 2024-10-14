package ecs

import "core:sync"
import "core:thread"

register_systems :: proc(w: ^World($T), systems: ..proc(_: ^World(T))) {
	append(&w.systems, ..systems)
}

// generic World(T) can't be used with threads, user must infer the type in his parallel system.
// `world_from_rawptr` can be used for convenience.
Parallel_System :: #type proc(_: rawptr)

@(deprecated="experimental")
register_parallel_systems :: proc(w: ^World($T), systems: ..Parallel_System) {
	append(&w.parallel_systems, ..systems)
}

// Convenience wrapper to convert basic system to `Parallel_System`
to_parallel_system :: proc($system: proc(_: ^World($T))) -> Parallel_System {
	return proc(ptr: rawptr) {system((^World(T))(ptr))}
}

@(private)
run_systems :: proc(world: ^World($T)) {
	for system in world.systems {
		system(world)
	}
}

// TODO allocator for each task?
@(private)
run_parallel_systems :: proc(world: ^World($T)) {
	system_count := len(world.parallel_systems)

	data := make([]Parallel_System_Task_Data, system_count)
	defer delete(data)

	wg := &sync.Wait_Group{}
	sync.wait_group_add(wg, system_count)

	// Adding tasks for every system
	for &system, i in world.parallel_systems {
		data[i] = Parallel_System_Task_Data {
			system = system,
			world  = world,
			wg     = wg,
		}

		thread.pool_add_task(world.pool, context.allocator, parallel_system_task_wrapper, &data[i])
	}

	sync.wait(wg)
	clear(&world.pool.tasks_done)
}

@(private)
Parallel_System_Task_Data :: struct {
	system: Parallel_System,
	world:  rawptr,
	wg:     ^sync.Wait_Group,
}

@(private)
parallel_system_task_wrapper :: proc(t: thread.Task) {
	data := (^Parallel_System_Task_Data)(t.data)^
	data.system(data.world)
	sync.wait_group_done(data.wg)
}
