package ecs

import "core:reflect"
import "core:sync"
import "core:thread"
import rl "vendor:raylib"


System :: proc(g: ^World) // TODO add delta

register_systems :: proc(w: ^World, systems: ..System) {
	append(&w.systems, ..systems)
}

register_parallel_systems :: proc(w: ^World, systems: ..System) {
	append(&w.parallel_systems, ..systems)
}

run_systems :: proc(world: ^World) {
	for system in world.systems {
		system(world)
	}
}

// TODO allocator for each task?
run_parallel_systems :: proc(world: ^World) {
	system_count := len(world.parallel_systems)

	data := make([]System_Task_Data, system_count)
	defer delete(data)

	wg := &sync.Wait_Group{}
	sync.wait_group_add(wg, system_count)
	log("added to wg", system_count)

	// Adding tasks for every system
	for &system, i in world.parallel_systems {
		data[i] = System_Task_Data {
			system = system,
			world  = world,
			wg     = wg,
		}

		thread.pool_add_task(world.pool, context.allocator, system_task_wrapper, &data[i])
		log("added task", i)
	}

	log("waiting")
	sync.wait(wg)
	clear(&world.pool.tasks_done)
	log("end")
}

System_Task_Data :: struct {
	system: System,
	world:  ^World,
	wg:     ^sync.Wait_Group,
}

system_task_wrapper :: proc(t: thread.Task) {
	data := (^System_Task_Data)(t.data)^
	data.system(data.world)
	sync.wait_group_done(data.wg)
}
